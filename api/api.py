from flask import Flask, request, jsonify
import subprocess
import os

app = Flask(__name__)
MARINA_BIN = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'marina', 'marina'))

@app.route('/')
def home():
    return 'Marina API is running behind Docker & HTTPS!'

@app.route('/marina', methods=['GET'])
def evaluate_formula():
    prop = request.args.get('laza')
    if prop is None or not prop.strip():
        response = {
            "success": False,
            "message": "Le paramètre 'laza' est requis et ne peut pas être vide."
        }
        return jsonify(response), 400

    process = subprocess.run(
        [MARINA_BIN, prop],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    if process.returncode == 0:
        return jsonify({
            "success": True,
            "formula": prop,
            "result": process.stdout.strip()
        }), 200
    elif process.returncode == 127:
        return jsonify({
            "success": False,
            "message": "L'exécutable Marina n'a pas été trouvé ou n'est pas exécutable."
        }), 500
    else:
        return jsonify({
            "success": False,
            "formula": prop,
            "error": process.stderr.strip(),
            "code": process.returncode
        }), 400



if __name__ == '__main__':
    port = int(os.environ.get('PORT', 10000))
    app.run(host='0.0.0.0', port=port)
