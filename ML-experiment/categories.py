from sentence_transformers import SentenceTransformer
import numpy as np

model = SentenceTransformer("all-MiniLM-L6-v2")

categories = [
    "Sleep",
    "Break",
    "Coding",
    "Errands",
    "Fitness",
    "Meditation",
    "Study",
    "Work",
    "Leisure",
    "Break",
]

category_embeddings = model.encode(categories, normalize_embeddings=True)


def classify(text):
    text_embedding = model.encode(text, normalized_embeddings=True)
    similarities = np.dot(category_embeddings, text_embedding)

    return sorted(zip(categories, similarities), key=lambda x: x[1], reverse=True)
