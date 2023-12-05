from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def home():
    index = b''
    with open("index.html", 'rb') as f:
        index = f.read()
    resp = app.make_response(index)
    resp.mimetype = "text/html"
    return resp

@app.route('/bete')
def bete():
    photo = b''
    with open("bete.jpg", 'rb') as f:
        photo = f.read()
    resp = app.make_response(photo)
    resp.mimetype = "image/jpg"
    return resp

if __name__ == '__main__':
    app.run(host="0.0.0.0", debug=False, port=8080)
