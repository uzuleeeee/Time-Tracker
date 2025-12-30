from categories import classify

tests = [
    "I'm going to walk to school",
    "Do laundry",
    "Fold paper crane",
    "Watch TV for a bit",
    "Go to sleep now",
    "Lift weights at gym",
]

for test in tests:
    print(f"\n{test}")
    similarities = classify(test)
    print(similarities)
