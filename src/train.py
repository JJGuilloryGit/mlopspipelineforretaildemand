import argparse
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
import joblib
import psycopg2

def train_model(db_host, db_name, db_user, db_password):
    # Create simple dummy data instead of DB connection for quick testing
    X = pd.DataFrame({'feature': range(100)})
    y = X['feature'] * 2 + 3 + np.random.normal(0, 0.1, 100)
    
    # Train a simple model
    model = LinearRegression()
    model.fit(X, y)
    
    # Save the model
    joblib.dump(model, 'models/model.pkl')
    return model

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--db-host", required=True)
    parser.add_argument("--db-name", required=True)
    parser.add_argument("--db-user", required=True)
    parser.add_argument("--db-password", required=True)
    args = parser.parse_args()
    
    model = train_model(args.db_host, args.db_name, args.db_user, args.db_password)
