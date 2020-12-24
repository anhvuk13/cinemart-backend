;;(get-admin-by-id config {:id 4})
;;(update-admin-by-id config {:id 4,
;;                            :dob nil,
;;                            :password
;;                            "bcrypt+sha512$7690d2633f3a42c238a5ba01088d376b$12$e9e953a01f3fa040e5b78de35993be79d23d53a67682c023",
;;                            :mail "admin@cinemart.com",
;;                            :created_at (clj-time.format/parse "2020-12-06T16:28:26.752Z")})
(ns cinemart.db
  (:require [custom.config :as c]
            [utils.coerce]
            [clj-time.core :refer [date-time]]
            [hugsql.core :as hugsql]
            [buddy.hashers :as h]))

(def config c/hugsql-config)

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
                       :dob (date-time 1970 1 1)}))

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
  (get-schedules config)
  (get-schedule-by-id config {:id 1})
  (get-schedules-by-theater-and-movie config {:id 1
                                              :movie 335984})
  (get-schedules-by-theater config {:theater 1})
  (get-schedules-by-week config {:year 2020
                                :month 12
                                :week 51})
  (get-schedules-by-date config {:year 2020
                                :month 12
                                :week 51
                                :day 19})
  (delete-user-by-id config {:id 4})
  (get-users config)
  (insert-user config {:fullname ""
                       :dob (clj-time.core/now)
                       :username ""
                       :password ""
                       :mail ""})
  (create-test config)
  (insert-test config {:j (utils.coerce/to-pg-json [{:a 1}])})
  (type {:a :b})
  (get-managers-by-theater config {:theater 1})
  (get-schedule-by-id config {:id 4})
  (get-reserved-seats-of-schedule config {:schedule 3})
  (get-users config)
  (get-movies config)
  (delete-user-by-id config {:id 1})
  (insert-movie config {:runtime 1
                      :genres (utils.coerce/to-pg-json [{:id 1 :name "a"}])
                      :overview "alo"
                      :title "title"
                      :poster_path "poster"
                      :backdrop_path "backpath"})
  (def
    obj
    (draw-movie config {:id 123
                        :runtime 120
                        :genres
                        (utils.coerce/to-pg-json
                        [{:id 123 :name "alice"}
                         {:id 321 :name "bob"}])
                        :overview "Hello"
                        :title "World"
                        :backdrop_path "/path/to/backdrop"
                        :poster_path "/path/to/poster"}))
  (map #(.getValue %) (:genres obj)))
