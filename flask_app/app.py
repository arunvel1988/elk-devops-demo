from flask import Flask
import logging

app = Flask(__name__)

# Configure Flask logging
logging.basicConfig(filename='/app/logs/app.log', level=logging.INFO, 
                    format='%(asctime)s - %(levelname)s - %(message)s')

@app.route("/")
def home():
    app.logger.info("Home Page Accessed")
    return "DevOps Flask Web Server!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
