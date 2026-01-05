import Foundation
import CoreML
import Accelerate
import Tokenizers

class Scorer {
    static let shared = Scorer(labelToDescriptions: Scorer.initialData)
    
    static let initialData: [String: [String]] = [
        "Sleep": [
            "sleeping", "going to sleep", "taking a nap", "napping", "heading to bed",
            "lying in bed", "trying to sleep", "resting", "fell asleep", "waking up"
        ],
        "Eat": [
            "eating", "having a meal", "eating food", "having breakfast", "having lunch",
            "having dinner", "grabbing a snack", "snacking", "drinking water", "getting food"
        ],
        "Work": [
            "working", "doing work", "at work", "working on tasks", "working on my job",
            "doing my job", "office work", "working on a project", "career work", "business work"
        ],
        "Study": [
            "studying", "doing homework", "studying for an exam", "learning", "reading notes",
            "reviewing material", "doing school work", "working on assignments", "exam prep", "studying concepts"
        ],
        "Commute": [
            "commuting", "driving to work", "traveling", "on the way", "heading somewhere",
            "walking to class", "taking the bus", "riding the train", "driving", "going somewhere"
        ],
        "Entertainment": [
            "watching tv", "watching a show", "watching a movie", "playing games", "gaming",
            "scrolling social media", "watching youtube", "browsing the internet", "entertainment", "relaxing with media"
        ],
        "Chores": [
            "doing chores", "cleaning", "doing laundry", "washing dishes", "tidying up",
            "housework", "organizing", "cleaning the house", "taking care of chores", "running household tasks"
        ],
        "Exercise": [
            "working out", "exercising", "going to the gym", "lifting weights", "doing cardio",
            "running", "jogging", "walking", "training", "fitness"
        ],
        "Social": [
            "hanging out", "spending time with friends", "talking with friends", "socializing",
            "meeting people", "chatting", "calling someone", "texting", "being social", "spending time together"
        ],
        "Break": [
            "taking a break", "on a break", "resting", "pausing", "stepping away",
            "short break", "cooling off", "doing nothing", "waiting", "idle"
        ],
        "Self Care": [
            "self care", "taking care of myself", "relaxing", "meditating", "mindfulness",
            "journaling", "breathing exercises", "therapy", "mental health", "winding down"
        ],
        "Hobby": [
            "working on a hobby", "doing a hobby", "creative work", "drawing", "writing",
            "playing music", "practicing an instrument", "building something", "personal project", "doing something I enjoy"
        ]
    ]
    
    private var labelToDescriptions: [String: [String]]
    private var labelToVectors: [String: [[Float]]] = [:]
    
    private let maxDescriptionLength: Int
    private let k: Int
    
    private var model: TextEmbedder?
    private var tokenizer: BertTokenizer?
    
    private var isLoading = false
    
    var isReady: Bool = false
    
    private var cacheURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("vectors_cache.json")
    }
    
    init(
        labelToDescriptions: [String: [String]] = [:],
        maxDescriptionLength: Int = 20,
        k: Int = 3
    ) {
        self.labelToDescriptions = labelToDescriptions
        self.maxDescriptionLength = maxDescriptionLength
        self.k = k
    }
    
    func setup() async {
        if isReady || isLoading { return }
        isLoading = true
        let totalStart = Date()
        
        // Load Model
        let t1 = Date()
        do {
            let config = MLModelConfiguration()
            config.computeUnits = .all
            self.model = try TextEmbedder(configuration: config)
            print("CoreML Model Loaded: \(Date().timeIntervalSince(t1))s")
        } catch {
            print("Failed to load Core ML model: \(error)")
            return
        }
        
        // Get Vocab URL
        let t2 = Date()
        guard let vocabURL = Bundle.main.url(forResource: "vocab", withExtension: "txt") ?? Bundle.main.url(forResource: "vocab", withExtension: "txt", subdirectory: "iOS_Resources/Tokenizer") else {
            print("FATAL: vocab.txt not found in Bundle.")
            return
        }
        
        // Load Tokenizer
        do {
            // Load Vocab
            let vocabText = try String(contentsOf: vocabURL, encoding: .utf8)
            var vocab: [String: Int] = [:]
            vocabText.enumerateLines { line, _ in
                if !line.isEmpty { vocab[line] = vocab.count }
            }
            
            // Load Tokenizer
            self.tokenizer = BertTokenizer(vocab: vocab, merges: [])
            print("Load Tokenizer: \(String(format: "%.3f", Date().timeIntervalSince(t2)))s")
        } catch {
            print("Tokenizer Error: \(error)")
            return
        }

        // Load Cache or Calculate Vectors
        let t3 = Date()
        if loadCache() {
            print("Vectors loaded from cache")
        } else {
            print("Calculating vectors...")
            // Calculate Vectors
            await withTaskGroup(of: Void.self) { group in
                group.addTask { self.initializeVectors() }
            }
            saveCache()
        }
        print("Load/Calculate Vectors: \(String(format: "%.3f", Date().timeIntervalSince(t3)))s")
    
        // Warm up model
        _ = textToVector("warm up")
        
        await MainActor.run {
            self.isReady = true
            self.isLoading = false
            let totalTime = Date().timeIntervalSince(totalStart)
            print("Scorer Ready: \(String(format: "%.2f", totalTime))s)")
            
            NotificationCenter.default.post(name: .modelReady, object: nil)
        }
    }
    
    private func saveCache() {
        guard let url = cacheURL else { return }
        do {
            let cacheData = ScorerCacheData(descriptions: self.labelToDescriptions, vectors: self.labelToVectors)
            let data = try JSONEncoder().encode(cacheData)
            try data.write(to: url)
        } catch {
            print("Failed to save to cache: \(error)")
        }
    }
    
    private func loadCache() -> Bool {
        guard let url = cacheURL, FileManager.default.fileExists(atPath: url.path) else { return false }
        do {
            let data = try Data(contentsOf: url)
            let cachedData = try JSONDecoder().decode(ScorerCacheData.self, from: data)
            
            // Load Validation
            if Set(cachedData.vectors.keys) != Set(labelToDescriptions.keys) {
                print("Cache outdated")
                return false
            }
            
            self.labelToDescriptions = cachedData.descriptions
            self.labelToVectors = cachedData.vectors
            
            return true
        } catch {
            print("Cache load failed \(error)")
            return false
        }
    }
    
    func predict(text: String) -> [(String, Float)] {
        // Convert Input to Vector
        guard isReady, let textVector = textToVector(text) else { return [] }
        
        var similarities: [(String, Float)] = []
        
        // Compare against all labels
        for (label, descriptionVectors) in labelToVectors {
            // Python: text_vector @ description_vectors.T
            let cosineScores = descriptionVectors.map { vec in
                vDSP.dot(textVector, vec)
            }
            
            // Top K Average
            // Python: np.sort(similarity)[-k:], then mean()
            let kActual = min(self.k, cosineScores.count)
            let topK = cosineScores.sorted(by: >).prefix(kActual)
            
            let sum = topK.reduce(0, +)
            let average = topK.isEmpty ? 0.0 : sum / Float(topK.count)
            
            similarities.append((label, average))
        }
        
        // Sort descending
        return similarities.sorted { $0.1 > $1.1 }
    }
    
    func createCategory(label: String) {
        print("Create Category: \(label)")
        if labelToDescriptions[label] == nil {
            labelToDescriptions[label] = []
            if let labelVec = textToVector(label) {
                labelToVectors[label] = [labelVec]
            }
            
            saveCache()
            
            print("Category '\(label)' created")
        } else {
            print("Category '\(label)' already exists")
        }
    }
    
    func updateDescriptions(label: String, description: String) {
        if labelToDescriptions[label] == nil {
            labelToDescriptions[label] = []
            if let labelVec = textToVector(label) {
                labelToVectors[label] = [labelVec]
            }
        }
        
        guard let descriptionVector = textToVector(description) else { return }
        
        // FIFO
        if (labelToDescriptions[label]?.count ?? 0) >= maxDescriptionLength {
            labelToDescriptions[label]?.removeFirst()
            if (labelToVectors[label]?.count ?? 0) > 1 {
                labelToVectors[label]?.remove(at: 1)
            }
        }
        
        labelToDescriptions[label]?.append(description)
        labelToVectors[label]?.append(descriptionVector)
        
        saveCache()
    }
    
    // Internal Helpers
    
    private func initializeVectors() {
        for (label, descriptions) in labelToDescriptions {
            let texts = [label] + descriptions
            let vectors = texts.compactMap { textToVector($0) }
            labelToVectors[label] = vectors
        }
    }
    
    private func textToVector(_ text: String) -> [Float]? {
        guard let model = model, let tokenizer = tokenizer else { return nil }
        
        // Make Lowercase
        let cleanText = text.lowercased()
        
        // Tokenize
        let tokens = tokenizer.tokenize(text: cleanText)
        var inputIds = tokenizer.convertTokensToIds(tokens).compactMap { $0 }
        
        // Add Special Tokens
        let clsId = tokenizer.convertTokenToId("[CLS]") ?? 101
        let sepId = tokenizer.convertTokenToId("[SEP]") ?? 102
        
        inputIds = [clsId] + inputIds + [sepId]
        
        if inputIds.isEmpty { return nil }
        let length = inputIds.count
        
        do {
            let inputIdsArray = try MLMultiArray(shape: [1, NSNumber(value: length)], dataType: .int32)
            let maskArray = try MLMultiArray(shape: [1, NSNumber(value: length)], dataType: .int32)
            
            for (i, id) in inputIds.enumerated() {
                inputIdsArray[i] = NSNumber(value: id)
                maskArray[i] = NSNumber(value: 1)
            }
            
            let output = try model.prediction(input_ids: inputIdsArray, attention_mask: maskArray)
            
            // Mean Pooling & Normalization
            let rawVector = flattenAndPool(output.last_hidden_state)
            return normalize(rawVector)
        } catch {
            print("Prediction Error: \(error)")
            return nil
        }
    }
    
    // np.mean(array, axis=1)
    private func flattenAndPool(_ multiArray: MLMultiArray) -> [Float] {
        let seqLen = multiArray.shape[1].intValue
        let dim = multiArray.shape[2].intValue
        
        let ptr = multiArray.dataPointer.bindMemory(to: Float.self, capacity: multiArray.count)
        let buffer = UnsafeBufferPointer(start: ptr, count: multiArray.count)
        
        var pooled = [Float](repeating: 0, count: dim)
        
        // Sum up all vectors in the sequence
        for i in 0..<seqLen {
            let offset = i * dim
            for j in 0..<dim {
                pooled[j] += buffer[offset + j]
            }
        }
        
        // Divide by sequence length to get mean
        for j in 0..<dim {
            pooled[j] /= Float(seqLen)
        }
        
        return pooled
    }
    
    // vector / np.linalg.norm(vector)
    private func normalize(_ vector: [Float]) -> [Float] {
        var result = vector
        var sum: Float = 0
        vDSP_svesq(vector, 1, &sum, vDSP_Length(vector.count)) // Sum of squares
        let norm = sqrt(sum)
        if norm == 0 { return vector }
        vDSP_vsdiv(vector, 1, [norm], &result, 1, vDSP_Length(vector.count)) // Divide by scalar
        return result
    }
}

// Helper for Dot Product
extension vDSP {
    static func dot(_ a: [Float], _ b: [Float]) -> Float {
        var result: Float = 0
        vDSP_dotpr(a, 1, b, 1, &result, vDSP_Length(a.count))
        return result
    }
}

// Notification extension for UI
extension Notification.Name {
    static let modelReady = Notification.Name("ModelReady")
}
