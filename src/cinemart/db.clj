(ns cinemart.db
  (:require [hugsql.core :as hugsql]
            [buddy.hashers :as hasher]))

(def config
  {:classname "org.postgresql.Driver"
   :subprotocol "postgresql"
   :subname "//localhost:5432/cinemart"
   :user "postgres"
   :password "postgres"})

(hugsql/def-db-fns "sql/contacts.sql")
(create-contacts-table config)

(hugsql/def-db-fns "sql/users.sql")
(create-users-table config)

(hugsql/def-db-fns "sql/schedules.sql")
(create-schedules-table config)

(hugsql/def-db-fns "sql/tickets.sql")
(create-tickets-table config)

(comment
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

