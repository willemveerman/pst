from flask import Flask
from flask import render_template
import requests
from json import JSONDecodeError
from requests.exceptions import ConnectionError

app = Flask(__name__)


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/products')
def products():

    source = 'https://reqres.in/api/products/'

    try:
        r = requests.get(source)
    except ConnectionError as e:
        error_message = f"Cannot reach products source '{source}'; {e}"
        return render_template('products.html', error_message=error_message)

    try:
        r.json()
    except JSONDecodeError:
        error_message = f"Cannot list products - source '{source}' didn't return json."
        app.logger.error(error_message)
        return render_template('products.html', error_message=error_message)

    try:
        product_list = r.json()["data"]
    except KeyError as e:
        error_message = f"Cannot list products - '{e}' key not returned by '{source}', got: {r.json()}"
        app.logger.error(error_message)
        return render_template('products.html', error_message=error_message)

    if product_list:
        try:
            product_list[0]["color"]
            product_list[0]["name"]
        except KeyError as e:
            error_message = f"Cannot list products - '{e}' key not returned by '{source}', got: {r.json()}"
            app.logger.error(error_message)
            return render_template('products.html', error_message=error_message)

    return render_template('products.html', product_list=product_list)


if __name__ == '__main__':
    app.run()
