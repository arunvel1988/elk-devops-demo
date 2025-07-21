from flask import Flask, render_template, request, jsonify
from datetime import datetime
import logging

app = Flask(__name__)

# Configure logging to file (Filebeat will pick this up)
logging.basicConfig(
    filename='logs/flask-app.log',
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s'
)

@app.route('/', methods=['GET'])
def index():
    client_ip = request.remote_addr
    user_agent = request.headers.get('User-Agent')
    logging.info(f"GET request from {client_ip} - {user_agent}")
    return render_template("index.html")

@app.route('/submit', methods=['POST'])
def submit():
    data = request.form.get('message')
    client_ip = request.remote_addr
    user_agent = request.headers.get('User-Agent')
    logging.info(f"POST from {client_ip}: {data} - {user_agent}")
    return jsonify({"status": "success", "message": "Received!"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
