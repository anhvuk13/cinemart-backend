(ns cinemart.db
  (:require [cinemart.config :as c]
            [hugsql.core :as hugsql]
            [buddy.hashers :as h]))

(defonce config c/db-config)

(hugsql/def-db-fns "sql/movies.sql")
(create-movies-table config)

(hugsql/def-db-fns "sql/theaters.sql")
(create-theaters-table config)

(hugsql/def-db-fns "sql/schedules.sql")
(create-schedules-table config)

(hugsql/def-db-fns "sql/users.sql")
(create-users-table config)
;; create john@doe.com:password if not exists
(when (not (get-user-by-mail config {:mail "john@doe.com"}))
  (insert-user config {:fullname "John Doe"
                       :username "johndoe"
                       :mail "john@doe.com"
                       :password (h/derive "john")
                       :dob "1/1/1970"}))

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
(when (not (get-admin-by-mail config {:mail "admin@cinemart.com"}))
  (insert-admin config {:mail "admin@cinemart.com"
                        :password (h/derive "admin")}))

(hugsql/def-db-fns "sql/auth.sql")
(create-auth-table config)

(comment
  (get-managers-by-theater config {:theater 1}))
