import socket
from flask import Flask
from redis import Redis

app = Flask(__name__)
redis = Redis(host='redis', port=6379)


@app.route('/')
def hello():
    count = redis.incr('hits')
    message = 'I have been seen {t} times. My Hostname is: {h} \n'.format(
        t=count, h=socket.gethostname()
    )
    with open('logs/app.log', 'a') as log:
        log.write(message)
    return str(count)


@app.route('/logs')
def logs():
    with open('logs/app.log', 'r') as log:
        return ''.join(list(map(lambda l: '<p>{l}</p>'.format(l=l), log.readlines())))


if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
