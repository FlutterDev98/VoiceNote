from flask import Flask, request, jsonify
from flask_cors import CORS
import whisper
import tempfile
import os
import ssl
import certifi
import logging

# Set up logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# Create an unverified SSL context
ssl._create_default_https_context = ssl._create_unverified_context

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Load the model with error handling
try:
    logger.info("Loading Whisper model...")
    model = whisper.load_model("base")
    logger.info("Model loaded successfully!")
except Exception as e:
    logger.error(f"Error loading model: {e}")
    raise

@app.route('/transcribe', methods=['POST'])
def transcribe():
    try:
        if 'file' not in request.files:
            logger.error("No file provided in request")
            return jsonify({'error': 'No file provided'}), 400
        
        file = request.files['file']
        
        if file.filename == '':
            logger.error("Empty filename")
            return jsonify({'error': 'No file selected'}), 400
        
        # Save the uploaded file temporarily
        with tempfile.NamedTemporaryFile(delete=False, suffix='.m4a') as temp_file:
            logger.info(f"Saving file to {temp_file.name}")
            file.save(temp_file.name)
            
            try:
                # Transcribe the audio
                logger.info("Starting transcription...")
                result = model.transcribe(temp_file.name)
                logger.info("Transcription completed successfully")
                
                # Clean up the temporary file
                os.unlink(temp_file.name)
                
                return jsonify({'text': result['text']})
            except Exception as e:
                logger.error(f"Error during transcription: {str(e)}")
                # Clean up the temporary file in case of error
                os.unlink(temp_file.name)
                return jsonify({'error': f'Transcription failed: {str(e)}'}), 500
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        return jsonify({'error': f'Server error: {str(e)}'}), 500

if __name__ == '__main__':
    app.run(port=9000, debug=True) 