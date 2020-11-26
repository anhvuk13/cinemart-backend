(ns cinemart.routes
  (:require [schema.core :as s]
            [reitit.swagger :as swagger]
            [ring.util.http-response :as res]
            [cinemart.middleware :as mw]
            [cinemart.auth :as auth]
            [cinemart.me :as me]
            [cinemart.users :as users]
            [cinemart.movies :as movies]
            [cinemart.schedules :as schedules]
            [cinemart.theaters :as theaters]
            [cinemart.tickets :as tickets]))

(def Bool (s/enum "true" "True" "false" "False"))

(def ping-routes
  ["/ping" {:swagger {:tags ["ping"]}
            :name :ping
            :get {:handler (fn [req]
                             (res/ok {:ping "pong"}))}}])

(def movie-routes
  ["/movies" {:swagger {:tags ["movies"]}}
   ["" {:get movies/get-movies
        :post movies/create-movie}]
   ["/:id" {:parameters {:path {:id s/Str}}
            :get movies/get-movie-by-id
            :put movies/update-movie
            :delete movies/delete-movie}]])

(def theater-routes
  ["/theaters" {:swagger {:tags ["theaters"]}}
   ["" {:get theaters/get-theaters
        :post {:parameters {:body {:name s/Str
                                   :address s/Str}}
               :middleware [mw/auth mw/admin]
               :handler theaters/create-theater}}]
   ["/:id" {:parameters {:path {:id s/Int}}
            :get theaters/get-theater-by-id
            :put {:middleware [mw/auth mw/manager-or-admin]
                  :parameters {:body {:name s/Str
                                      :address s/Str}}
                  :handler theaters/update-theater}
            :delete {:middleware [mw/auth mw/admin]
                     :handler theaters/delete-theater}}]])

(def user-routes
  ["/users" {:middleware [mw/auth mw/admin]
             :parameters {:header {(s/optional-key :authorization) s/Str}}
             :swagger {:tags ["users"]}}
   ["" {:get users/get-users
        :post {:parameters {:body {:fullname s/Str
                                   :dob s/Str
                                   :username s/Str
                                   :password s/Str
                                   :mail s/Str}}
               :middleware [mw/create-user]
               :handler users/create-user}}]
   ["/:id" {:parameters {:path {:id s/Int}}
            :get users/get-user-by-id
            :put {:parameters {:body {:fullname s/Str
                                      :dob s/Str
                                      :username s/Str
                                      :password s/Str
                                      :mail s/Str}}
                  :handler users/update-user}
            :delete users/delete-user}]])

(def ticket-routes
  ["/tickets" {:swagger {:tags ["tickets"]}
               :middleware [mw/auth]
               :parameters {:header {(s/optional-key :authorization) s/Str}}
               :post {:parameters {:body {:invoice s/Int
                                          :seat s/Int
                                          :price s/Int}}
                      :handler tickets/create-ticket}
               :delete {:parameters {:body {:invoice s/Int
                                            :seat s/Int}}
                        :handler tickets/delete-ticket}}])

(def schedule-routes
  ["/schedules" {:swagger {:tags ["schedules"]}}
   ["" {:get schedules/get-schedules
        :post {:parameters {:body {:film s/Str
                                   :room s/Str
                                   :time s/Str
                                   :seats s/Int}}
               :middleware [mw/auth]
               :handler schedules/create-schedule}}]
   ["/:id" {:parameters {:path {:id s/Int}}
            :get schedules/get-schedule-by-id
            :put {:parameters {:body {:film s/Str
                                      :room s/Str
                                      :time s/Str}}
                  :middleware [mw/auth mw/admin]
                  :handler schedules/update-schedule}
            :delete {:middleware [mw/auth mw/admin]
                     :handler schedules/delete-schedule}}]])

(def me-routes ["/me" {:swagger {:tags ["me"]}
                       :parameters {:header {(s/optional-key :authorization) s/Str}}
                       :middleware [mw/auth]
                       :get me/get-my-info
                       :put {:parameters {:body {(s/optional-key :fullname) s/Str
                                                 (s/optional-key :username) s/Str
                                                 (s/optional-key :mail) s/Str
                                                 (s/optional-key :password) s/Str
                                                 (s/optional-key :dob) s/Str}}
                             :middleware [mw/hashpass]
                             :handler me/update-my-info}}])

(def refresh-token ["/refresh-token" {:swagger {:tags ["auth"]}
                                      :parameters {:header {(s/optional-key :authorization) s/Str}}
                                      :post {:middleware [mw/reauth]
                                             :handler auth/refresh}}])

(def login ["/login" {:swagger {:tags ["auth"]}
                      :post {:parameters {:body {:mail s/Str
                                                 :password s/Str}}
                             :handler (fn [req]
                                        (auth/login req "user"))}}])

(def logout ["/logout" {:swagger {:tags ["auth"]}
                        :parameters {:header {(s/optional-key :authorization) s/Str}}
                        :middleware [mw/auth]}
             ["" {:post auth/logout}]
             ["/other-devices" {:post auth/logout-from-other-devices}]])

(def register ["/register" {:swagger {:tags ["auth"]}
                            :post {:parameters {:body {:username s/Str
                                                       :mail s/Str
                                                       :password s/Str
                                                       :dob s/Str
                                                       :fullname s/Str}}
                                   :middleware [mw/create-user mw/hashpass]
                                   :handler (fn [req]
                                              (auth/register req "user"))}}])
