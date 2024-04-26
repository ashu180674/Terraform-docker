from flask import Flask, jsonify
import random

app = Flask(__name__)

strings = ["Investments", "Smallcase", "Stocks", "buy-the-dip", "TickerTape"]

@app.route('/api/v1')
def get_random_string():
    return jsonify({"string": random.choice(strings)})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8081)
