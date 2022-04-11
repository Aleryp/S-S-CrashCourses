FROM python:alpine3.15

WORKDIR /flask

COPY app.py /flask
ADD index.html /flask/templates/
RUN pip3 install flask

CMD ["python3", "app.py"]

EXPOSE 5000
