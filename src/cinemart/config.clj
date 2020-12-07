(ns cinemart.config)

;; secret key to sign jwt
(def secret "secret")

;; token life time (in second)
(def token-valid 1800)

;; refresh-token life time (in second)
(def ref-token-valid 3600)

;; postgres
(def db-config {:classname "org.postgresql.Driver"
                :subprotocol "postgresql"
                :subname "//db:5432/cinemart"
                :user "postgres"
                :password "postgres"})
