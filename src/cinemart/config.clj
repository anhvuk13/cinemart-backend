(ns cinemart.config)

;; secret key to sign jwt
(defonce secret "secret")

;; token life time (in second)
(defonce token-valid 1800)

;; refresh-token life time (in second)
(defonce ref-token-valid 3600)

;; postgres
(defonce db-config {:classname "org.postgresql.Driver"
                    :subprotocol "postgresql"
                    :subname "//db:5432/cinemart"
                    :user "postgres"
                    :password "postgres"})
