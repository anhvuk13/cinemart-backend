FROM clojure
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY deps.edn /usr/src/app/
RUN clojure -Spath
COPY . /usr/src/app
