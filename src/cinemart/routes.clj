(ns cinemart.routes
  (:require [schema.core :as s]
            [ring.util.http-response :as res]
            [cinemart.middleware :as mw]
            [cinemart.auth :as auth]
            [cinemart.users :as users]
            [cinemart.schedules :as schedules]
            [cinemart.tickets :as tickets]))

(def ping-routes
  ["/ping" {:name :ping
            :get {:middleware [mw/authenticate mw/admin]
                  :handler (fn [req]
                             (res/ok {:ping "pong"}))}}])

(def user-routes
  ["/users"
   ["" {:get users/get-users
        :post {:parameters {:body {:fullname s/Str
                                   :dob s/Str
                                   :username s/Str
                                   :password s/Str
                                   :mail s/Str
                                   :admin s/Str}}
               :middleware [[mw/bool-field-convert :admin] mw/create-user]
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
  ["/tickets"
   ["" {:get tickets/get-tickets
        :post {:parameters {:body {:user-id s/Int
                                   :schedule-id s/Int
                                   :seat s/Int}}
               :handler tickets/create-ticket}}]
   ["/:id" {:get tickets/get-ticket-by-id
            :put {:parameters {:body {:user-id s/Int
                                      :schedule-id s/Int
                                      :seat s/Int}}
                  :handler tickets/update-ticket}
            :delete tickets/delete-ticket}]])

(def schedule-routes
  ["/schedules"
   ["" {:get schedules/get-schedules
        :post {:parameters {:body {:film s/Str
                                   :room s/Str
                                   :time s/Str
                                   :seats s/Int}}
               :handler schedules/create-schedule}}]
   ["/:id" {:get schedules/get-schedule-by-id
            :put {:parameters {:body {:film s/Str
                                      :room s/Str
                                      :time s/Str}}
                  :handler schedules/update-schedule}
            :delete schedules/delete-schedule}]])

(def login ["/login" {:post {:parameters {:body {:mail s/Str
                                                 :password s/Str}}
                             :handler auth/login}}])

(def register ["/register" {:post {:parameters {:body {:username s/Str
                                                       :mail s/Str
                                                       :password s/Str
                                                       :dob s/Str
                                                       :fullname s/Str}}
                                   :middleware [mw/add-admin-field mw/create-user]
                                   :handler users/create-user}}])
