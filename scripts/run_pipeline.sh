
#!/bin/bash
set -e

echo "Starting MLOps pipeline..."

pip install -r requirements.txt

echo "Running data processing..."
python scripts/data_processing.py

echo "Training model..."
python scripts/train_model.py

echo "Deploying model..."
python scripts/deploy_model.py

echo "MLOps pipeline completed successfully!"
