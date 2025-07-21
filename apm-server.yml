from flask import Flask, render_template, request, jsonify
import time
import logging
from elasticapm.contrib.flask import ElasticAPM

app = Flask(__name__)

# Elastic APM configuration
app.config['ELASTIC_APM'] = {
    'SERVICE_NAME': 'flask-web-app',
    'SECRET_TOKEN': '',
    'SERVER_URL': 'http://apm-server:8200',
    'ENVIRONMENT': 'development'
}

apm = ElasticAPM(app)

# Logging configuration
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

@app.route('/error')
def generate_error():
    raise RuntimeError("This is a test error for APM.")

@app.route('/slow')
def slow_response():
    time.sleep(5)
    return "This was a slow request"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
