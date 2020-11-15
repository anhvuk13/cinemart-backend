# cinemart

Just a simple web server written in [Clojure](https://clojure.org/)

## Run

- Start web server

```bash
clj -M:run
```

- Start dev server (nREPL)

```bash
clj -M:repl
```

## Docker

- Watch

```bash
docker-compose up
```

- Detach

```bash
docker-compose up -d
```

- Remove

```bash
docker-compose down
```

- Postgres

```bash
docker exec -it cinemart_db psql -U postgres
```

## APIs

- Documentation at [localhost](http://localhost:4000)
- Powered by [Swagger](https://swagger.io)

## Demo

- Server at https://violeine.duckdns.org
- Thanks to [violeine](https://github.com/violeine)

## Authors

- [violeine](https://github.com/violeine)
- [me](https://github.com/anhvuk13)

## Ref.

- [cinemart-frontend](https://github.com/violeine/cinemart-frontend) by [violeine](https://github.com/violeine)
