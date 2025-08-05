from flask import Flask, request, jsonify
import subprocess
import os

app = Flask(__name__)
MARINA_BIN = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'marina', 'marina'))

@app.route('/')
def home():
    return 'Marina API is running behind Docker & HTTPS!'


@app.route('/evaluate', methods=['POST'])
def evaluate():
    if not request.is_json:
        return jsonify({"error": "Invalid or missing JSON"}), 400

    data = request.get_json(force=True)
    formula = data.get("formula")
    values = data.get("values")

    if not formula or values is None:
        return jsonify({"error": "Missing 'formula' or 'values'"}), 400

    cmd = [MARINA_BIN, formula] + values
    try:
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
        return jsonify({
            "input": cmd,
            "output": result.stdout.strip()
        })
    except subprocess.CalledProcessError as e:
        return jsonify({
            "error": e.stderr.strip(),
            "exit_code": e.returncode
        }), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 10000))
    app.run(host='0.0.0.0', port=port)
