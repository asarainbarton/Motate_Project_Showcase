#!/usr/bin/env python3
"""
Startup script for the Emotion Journal API server
"""
import subprocess
import sys
import os

def check_requirements():
    """Check if required packages are installed"""
    try:
        import fastapi
        import uvicorn
        import transformers
        import torch
        print("✅ All required packages are installed")
        return True
    except ImportError as e:
        print(f"❌ Missing required package: {e}")
        print("Please install requirements with: pip install -r requirements.txt")
        return False

def main():
    print("🚀 Starting Emotion Journal API Server...")
    print("=" * 50)
    
    # Check if we're in the right directory
    if not os.path.exists("main.py"):
        print("❌ Error: main.py not found. Please run this script from the backend directory.")
        sys.exit(1)
    
    # Check requirements
    if not check_requirements():
        sys.exit(1)
    
    print("📡 Starting server on http://localhost:8000")
    print("📊 API documentation available at http://localhost:8000/docs")
    print("🔄 Press Ctrl+C to stop the server")
    print("=" * 50)
    
    try:
        # Start the server
        subprocess.run([
            sys.executable, "-m", "uvicorn", 
            "main:app", 
            "--host", "0.0.0.0", 
            "--port", "8000", 
            "--reload"
        ])
    except KeyboardInterrupt:
        print("\n👋 Server stopped by user")
    except Exception as e:
        print(f"❌ Error starting server: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
