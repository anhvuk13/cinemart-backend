FROM arm32v7/clojure:tools-deps
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . /usr/src/app
RUN clojure -Spath
