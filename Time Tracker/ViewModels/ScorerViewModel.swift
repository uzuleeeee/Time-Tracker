//
//  ScorerViewModel.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/27/25.
//

import SwiftUI
internal import Combine

class ScorerViewModel: ObservableObject {
    private let scorer: Scorer
    private var cancellables = Set<AnyCancellable>()
    
    @Published var inputText = ""
    @Published var isReady = false
    @Published var results: [(String, Float)] = []
    
    init() {
        self.scorer = Scorer.shared
        
        if scorer.isReady {
            self.isReady = true
        }
        
        // Listen for ready notification
        NotificationCenter.default.publisher(for: .modelReady)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isReady = true
            }
            .store(in: &cancellables)
        
        $inputText
            .dropFirst()
            .debounce(for: .seconds(0.1), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.predict(text)
            }
            .store(in: &cancellables)
    }
    
    func predict(_ text: String) {
        if !isReady { return }
        
        let currentText = text
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            
            let newResults = scorer.predict(text: currentText)
            
            await MainActor.run {
                self.results = newResults
            }
        }
    }
    
    // Called when user saves a new activity
    func updateModel(label: String, description: String) {
        scorer.updateDescriptions(label: label, description: description)
    }
}
