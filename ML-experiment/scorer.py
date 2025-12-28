import numpy as np
from sentence_transformers import SentenceTransformer
from typing import Dict


class Scorer:
    def __init__(
        self,
        label_to_descriptions: Dict[str, list[str]],
        model: str = "all-MiniLM-L6-v2",
        max_description_length: int = 20,
        k: int = 3,
    ):
        self.label_to_descriptions = label_to_descriptions
        self.model = SentenceTransformer(model, trust_remote_code=True)
        self.max_description_length = max_description_length
        self.k = k

        self.label_to_description_vectors: Dict[str, np.ndarray] = {}

    def texts_to_vectors(self, texts: list[str]) -> np.ndarray:
        """
        Encode text to vector embedding

        Args:
            texts (list[str]): (M, ) list of texts to embed

        Returns:
            np.ndarray: (M, D) embedded text vector
        """
        return self.model.encode(
            texts, normalize_embeddings=True, convert_to_numpy=True
        )

    def initialize_vectors(self):
        for label, descriptions in self.label_to_descriptions.items():
            description_vectors = self.texts_to_vectors(
                [label] + descriptions
            )  # (M + 1, D)

            self.label_to_description_vectors[label] = description_vectors

    def predict(self, text):
        similarities = []

        text_vector = self.texts_to_vectors([text])  # (1, D)

        for label, description_vectors in self.label_to_description_vectors.items():
            similarity_matrix = text_vector @ description_vectors.T  # (1, M + 1)
            similarity = similarity_matrix[0]
            k = min(self.k, len(similarity))
            top_k_similarities = np.sort(similarity)[-k:]
            average_similarity = float(np.mean(top_k_similarities))  # (np.float32)

            similarities.append((label, average_similarity))  # (str, np.float32)

        similarities = sorted(similarities, key=lambda x: x[1], reverse=True)

        return similarities

    def update_descriptions(self, label, description):
        if label not in self.label_to_descriptions:
            self.label_to_descriptions[label] = []
            self.label_to_description_vectors[label] = self.texts_to_vectors([label])

        description_vector = self.texts_to_vectors([description])  # (1, D)

        if len(self.label_to_descriptions[label]) >= self.max_description_length:
            self.label_to_descriptions[label] = self.label_to_descriptions[label][1:]
            self.label_to_description_vectors[label] = np.delete(
                self.label_to_description_vectors[label], 1, axis=0
            )  # remove element at index 1

        self.label_to_descriptions[label].append(description)
        self.label_to_description_vectors[label] = np.vstack(
            (self.label_to_description_vectors[label], description_vector)
        )
