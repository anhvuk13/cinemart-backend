(ns custom.config)

;; backend server
(def server-path "http://localhost:4000/")

;; secret key to sign jwt
(def secret "secret")

;; token life time (in second)
(def token-valid 1800)

;; refresh-token life time (in second)
(def ref-token-valid 3600)

;; postgres
(def hugsql-config {:classname "org.postgresql.Driver"
                    :subprotocol "postgresql"
                    :subname "//db:5432/cinemart"
                    :user "postgres"
                    :password "postgres"})

(def jdbc-config {:host "db"
                  :port "5432"
                  :dbtype "postgresql"
                  :dbname "cinemart"
                  :user "postgres"
                  :password "postgres"})
