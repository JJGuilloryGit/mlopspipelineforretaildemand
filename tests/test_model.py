import pytest
import numpy as np
from sklearn.linear_model import LinearRegression

def test_model_prediction():
    # Simple test with dummy data
    X = np.array([[1], [2], [3]])
    y = np.array([2, 4, 6])
    
    model = LinearRegression()
    model.fit(X, y)
    
    prediction = model.predict([[4]])
    assert abs(prediction - 8) < 0.1

def test_data_shape():
    X = np.array([[1], [2], [3]])
    assert X.shape[1] == 1
