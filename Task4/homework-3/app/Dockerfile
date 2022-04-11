FROM python:3.6.15-alpine

WORKDIR /hits
COPY /hits/app.py /hits
COPY requirements.txt /hits/
RUN pip3 install -r requirements.txt
RUN mkdir logs
CMD ["python3", "app.py"]
