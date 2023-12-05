FROM alpine:3.18.5

RUN apk add --no-cache tini python3 py3-pip
ENTRYPOINT [ "/sbin/tini", "--" ]

COPY server/ /server

WORKDIR /server

RUN pip3 install -r requirements.txt
EXPOSE 8080

CMD [ "python3", "app.py" ]
