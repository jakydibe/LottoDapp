from flask import Flask, jsonify
import random
from flask_cors import CORS, cross_origin
import subprocess
import json
import logging


app = Flask(__name__)

# Configurazione CORS completa
CORS(app, 
    resources={r"/trigger-oracle": {
        "origins": "*",
        "methods": "*",
        "allow_headers": "*"
    }},
    supports_credentials=True
)

@app.route('/random', methods=['GET'])
def get_random():
    # Genera un numero casuale tra 0 e 100
    random_number = random.randint(0, 100)
    return jsonify({"random": random_number})


@app.route('/trigger-oracle', methods=['POST', 'OPTIONS'])
@cross_origin()
def trigger_oracle():
    try:
        result = subprocess.run(
            ['python3', 'oracolo.py'],
            capture_output=True,
            text=True,
            timeout=30
        )

        # Cerca l'output JSON sia in stdout che stderr
        output_lines = result.stdout.split('\n') + result.stderr.split('\n')
        json_response = None
        
        for line in output_lines:
            try:
                json_response = json.loads(line)
                break
            except json.JSONDecodeError:
                continue

        if not json_response:
            raise ValueError("Nessun output JSON valido trovato")

        if result.returncode != 0 or json_response.get('status') == 'error':
            return jsonify({
                "error": json_response.get('message', 'Errore sconosciuto'),
                "debug": output_lines
            }), 500

        return jsonify(json_response), 200

    except Exception as e:
        return jsonify({
            "error": str(e),
            "debug": output_lines if 'output_lines' in locals() else []
        }), 500
if __name__ == '__main__':
    app.run(debug=True, port=5000)
