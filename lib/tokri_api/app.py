# app.py

from flask import Flask, request, jsonify
from test_model import generate_weekly_basket  # import from test_model.py

app = Flask(__name__)

@app.route('/generate-basket', methods=['POST'])
def generate_basket():
    data = request.get_json()
    family_size = data.get('familySize', 3)

    try:
        basket = generate_weekly_basket(family_size)
        return jsonify(basket)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
