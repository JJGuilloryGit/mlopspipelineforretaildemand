FROM python:3.9-slim

WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy model and application code
COPY models/ models/
COPY src/ src/

# Expose the port the app runs on
EXPOSE 5000

# Command to run the application
CMD ["python", "src/serve.py"]
