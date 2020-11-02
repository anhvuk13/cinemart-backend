(ns cinemart.db
  (:require [hugsql.core :as hugsql]))

(def config
  {:classname "org.postgresql.Driver"
   :subprotocol "postgresql"
   :subname "//localhost:5432/cinemart"
   :user "postgres"
   :password "postgres"})

(hugsql/def-db-fns "sql/contacts.sql")

(hugsql/def-db-fns "sql/users.sql")

(comment
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

