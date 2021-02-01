FROM python:3.9.1-alpine

RUN mkdir /app

COPY app/ /app/

WORKDIR /app

RUN pip3 install -r requirements.txt

ENV FLASK_APP=app.py

USER 1000

ENTRYPOINT ["python3", "-m", "flask", "run", "--host=0.0.0.0"]

CMD ["--port=5000"]
