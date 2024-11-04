
FROM python:3.9

WORKDIR /src

COPY . /src

RUN pip install flask

RUN pip install flask_restful

EXPOSE 3333

ENTRYPOINT ["python"]

CMD ["./src/helloworld.py"]