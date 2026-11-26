from ollama import embed
from math import sqrt

texts = [
    "White PVC window frame",
    "White vinyl frame",
    "Chocolate cake"
]

vectors = {}

for text in texts:
    response = embed(
        model="nomic-embed-text",
        input=text
    )
    vectors[text] = response["embeddings"][0]

def cosine_similarity(a, b):
    dot = sum(x*y for x, y in zip(a, b))
    mag_a = sqrt(sum(x*x for x in a))
    mag_b = sqrt(sum(x*x for x in b))
    return dot / (mag_a * mag_b)

print(
    cosine_similarity(
        vectors["White PVC window frame"],
        vectors["White vinyl frame"]
    )
)

print(
    cosine_similarity(
        vectors["White PVC window frame"],
        vectors["Chocolate cake"]
    )
)