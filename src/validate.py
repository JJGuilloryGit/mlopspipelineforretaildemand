import argparse
import joblib
import numpy as np

def validate_model(model_path, threshold):
    # Load the model
    model = joblib.load(model_path)
    
    # Simple validation
    test_prediction = model.predict([[10]])
    expected_value = 23  # Based on y = 2x + 3
    error = abs(test_prediction - expected_value)
    
    return error < threshold

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--model-path", required=True)
    parser.add_argument("--threshold", type=float, required=True)
    args = parser.parse_args()
    
    is_valid = validate_model(args.model_path, args.threshold)
    if not is_valid:
        exit(1)
