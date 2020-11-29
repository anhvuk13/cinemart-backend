(ns cinemart.db
  (:require [hugsql.core :as hugsql]
            [buddy.hashers :as h]))

(def config
  {:classname "org.postgresql.Driver"
   :subprotocol "postgresql"
   :subname "//db:5432/cinemart"
   :user "postgres"
   :password "postgres"})

(hugsql/def-db-fns "sql/movies.sql")
(create-movies-table config)

(hugsql/def-db-fns "sql/theaters.sql")
(create-theaters-table config)

(hugsql/def-db-fns "sql/schedules.sql")
(create-schedules-table config)

(hugsql/def-db-fns "sql/users.sql")
(create-users-table config)

(hugsql/def-db-fns "sql/invoices.sql")
(create-invoices-table config)

(hugsql/def-db-fns "sql/tickets.sql")
(create-tickets-table config)

(hugsql/def-db-fns "sql/managers.sql")
(create-managers-table config)

(hugsql/def-db-fns "sql/management.sql")
(create-management-table config)

(hugsql/def-db-fns "sql/admins.sql")
(create-admins-table config)
;; add admin if no admin exists
(if (= 0 (:count (count-admins config)))
  (insert-admin config {:mail "admin@cinemart.com"
                        :password (h/derive "admin")}))

(hugsql/def-db-fns "sql/auth.sql")
(create-auth-table config)

(comment)
