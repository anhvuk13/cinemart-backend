# cinemart

Just a simple web server written in [Clojure](https://clojure.org/)

## Demo

- Web: https://cinemart.duckdns.org (Thanks to [violeine](https://github.com/violeine))
- APIs Doc: https://api.cinemart.duckdns.org (Powered by [Swagger](https://swagger.io))

## Ref.

- [cinemart-frontend](https://github.com/violeine/cinemart-frontend) by [violeine](https://github.com/violeine)

## Run

- Download dependencies

```bash
clj -Spath
```

- Start web server

```bash
clj -M:run
```

- Start dev server (nREPL)

```bash
clj -M:repl
```

## Docker

- Switch to web server

```bash
sed -i 's/\("-M:docker-repl"\|"-M:run"\)/"-M:run"/g' docker-compose.yml
```

- Switch to dev server

```bash
sed -i 's/\("-M:docker-repl"\|"-M:run"\)/"-M:docker-repl"/g' docker-compose.yml
```

- Run server

```bash
docker-compose up
```

- Run & Detach server

```bash
docker-compose up -d
```

- Shutdown server

```bash
docker-compose down
```

- Postgres

```bash
docker exec -it cinemart_db psql -U postgres
```

## Authors

- [violeine](https://github.com/violeine)
- [me](https://github.com/anhvuk13)
