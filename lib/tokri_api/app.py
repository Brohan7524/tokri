from flask import Flask, request, jsonify
from flask_cors import CORS
from model import generate_weekly_basket

app = Flask(__name__)
CORS(app)  # Allow requests from Flutter/web clients

# POST route for Flutter app
@app.route('/generate-basket', methods=['POST'])
def generate_basket():
    data = request.get_json()
    if not data or 'family_size' not in data:
        return jsonify({'error': 'Missing family_size'}), 400

    family_size = int(data['family_size'])
    basket = generate_weekly_basket(family_size)
    return jsonify({'weekly_basket': basket})

if __name__ == '__main__':
    app.run(debug=True)
