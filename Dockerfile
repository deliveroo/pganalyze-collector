FROM gliderlabs/alpine:edge
MAINTAINER team@pganalyze.com

RUN adduser -D pganalyze pganalyze
ENV GOPATH /go
ENV HOME_DIR /home/pganalyze
ENV CODE_DIR $GOPATH/src/github.com/pganalyze/collector

COPY . $CODE_DIR
WORKDIR $CODE_DIR

# We run this all in one layer to reduce the resulting image size
RUN apk-install -t build-deps make curl libc-dev gcc go git \
  && curl -o /usr/local/bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/1.6/gosu-amd64" \
  && go get -d \
  && make -C $GOPATH/src/github.com/lfittl/pg_query.go build \
  && go get \
  && go build -o $HOME_DIR/collector \
  && rm -rf $GOPATH \
	&& apk del --purge build-deps

RUN chmod +x /usr/local/bin/gosu
RUN chown pganalyze:pganalyze $HOME_DIR/collector

CMD ["/usr/local/bin/gosu", "pganalyze", "/home/pganalyze/collector"]
