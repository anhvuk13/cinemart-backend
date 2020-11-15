(ns cinemart.db
  (:require [hugsql.core :as hugsql]))

(def config
  {:classname "org.postgresql.Driver"
   :subprotocol "postgresql"
   :subname "//db:5432/cinemart"
   :user "postgres"
   :password "postgres"})

(hugsql/def-db-fns "sql/users.sql")
(create-users-table config)

(hugsql/def-db-fns "sql/movies.sql")
(create-movies-table config)

(hugsql/def-db-fns "sql/schedules.sql")
(create-schedules-table config)

(hugsql/def-db-fns "sql/tickets.sql")
(create-tickets-table config)

(hugsql/def-db-fns "sql/auth.sql")
(create-auth-table config)

(comment
  (delete-all-but-current-auth config {:user-id 2
                                       :token "eyJhbGciOiJIUzI1NiJ9.eyJhZG1pbiI6ZmFsc2UsInBhc3N3b3JkIjoiYmNyeXB0K3NoYTUxMiQ2NmQ1MDhmYmQ3NmZmNTc5YjcyMDYxMmVlODRjNzY3YSQxMiQyNjE3NDFiNWQwZmRjNmIwZTQ2NDk2M2RkZTE4NTNhNDA4ZDRjYWI0ZjgwZTlhMTAiLCJtYWlsIjoic3RyaW5nIiwiZXhwIjoxNjA1NDY2MjQ1OTI4LCJ1c2VybmFtZSI6InN0cmluZyIsImZ1bGxuYW1lIjoic3RyaW5nIiwiZG9iIjoic3RyaW5nIiwiaWQiOjIsImNyZWF0ZWRfYXQiOjE2MDU0NTUxODd9.ZujYDPZU0yb_ZkxMp5q5s1NWprt8YH3GebBNdt8XdOg"})
  (insert-auth config {:user-id 16 :token "t" :refresh-token "r"})
  (count-auth config {:user-id 16})
  (get-auth-by-user-id config {:user-id 16})
  (get-auth-by-token config {:token "t"})
  (get-auth-by-refresh-token config {:refresh-token "r"})
  (delete-auth-by-user-id config {:user-id 16})
  (get-user-by-mail config {:mail "john@doe.com"})
  (drop-tickets-table config)
  (drop-users-table config)
  (drop-schedules-table config)
  (get-users config)
  (insert-user config {:fullname "John doe"
                       :dob "1990-1-1"
                       :username "johndoe"
                       :password (hasher/derive "password")
                       :mail "john@doe.com"})
  (insert-schedule config {:film "1"
                           :time "1-1-2000"
                           :seats 200
                           :room "1"})
  (create-contacts-table config)
  (get-contacts config)
  (get-contact-by-id config {:id 1})
  (get-first-last config)
  (get-contact-by-id config {:id 2})
  (insert-contact config {:first-name "ha"
                          :last-name "micheal"
                          :email "john@doe.com"})
  (get-contact-by-id config
                     (insert-contact config
                                     {:first-name "ha"
                                      :last-name "hm"
                                      :email "j@d.com"})))

