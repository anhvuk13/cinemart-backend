(ns cinemart.routes
  (:require [schema.core :as s]
            [reitit.swagger :as swagger]
            [ring.util.http-response :as res]
            [cinemart.middleware :as mw]
            [cinemart.auth :as auth]
            [cinemart.users :as users]
            [cinemart.schedules :as schedules]
            [cinemart.tickets :as tickets]))

(def ping-routes
  ["/ping" {:parameters {:header {:authorization s/Str}}
            :swagger {:tags ["test"]}
            :name :ping
            :get {:middleware [mw/authenticate]
                  :handler (fn [req]
                             (res/ok {:ping "pong"}))}}])

(def user-routes
  ["/users" {:middleware [mw/authenticate mw/admin]
             :parameters {:header {:authorization s/Str}}
             :swagger {:tags ["users"]}}
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
  ["/tickets" {:swagger {:tags ["tickets"]}
               :middleware [mw/authenticate]
               :parameters {:header {:authorization s/Str}}}
   ["" {:get {:middleware [mw/admin]
              :handler tickets/get-tickets}
        :post {:parameters {:body {:user-id s/Int
                                   :schedule-id s/Int
                                   :seat s/Int}}
               :handler tickets/create-ticket}}]
   ["/:id" {:parameters {:path {:id s/Int}}
            :get tickets/get-ticket-by-id
            :put {:parameters {:body {:user-id s/Int
                                      :schedule-id s/Int
                                      :seat s/Int}}
                  :handler tickets/update-ticket}
            :delete tickets/delete-ticket}]])

(def schedule-routes
  ["/schedules" {:swagger {:tags ["schedules"]}}
   ["" {:get schedules/get-schedules
        :post {:parameters {:body {:film s/Str
                                   :room s/Str
                                   :time s/Str
                                   :seats s/Int}}
               :middleware [mw/authenticate]
               :handler schedules/create-schedule}}]
   ["/:id" {:parameters {:path {:id s/Int}}
            :get schedules/get-schedule-by-id
            :put {:parameters {:body {:film s/Str
                                      :room s/Str
                                      :time s/Str}}
                  :middleware [mw/authenticate mw/admin]
                  :handler schedules/update-schedule}
            :delete {:middleware [mw/authenticate mw/admin]
                     :handler schedules/delete-schedule}}]])

(def token ["/token" {:swagger {:tags ["auth"]}
                      :post {:middleware [mw/reauthenticate]
                             :handler auth/refresh}}])

(def login ["/login" {:swagger {:tags ["auth"]}
                      :post {:parameters {:body {:mail s/Str
                                                 :password s/Str}}
                             :handler auth/login}}])

(def logout ["/logout" {:swagger {:tags ["auth"]}
                        :parameters {:header {:authorization s/Str}}
                        :middleware [mw/authenticate]}
             ["" {:post auth/logout}]
             ["/all" {:post auth/logout-all}]])

(def register ["/register" {:swagger {:tags ["auth"]}
                            :post {:parameters {:body {:username s/Str
                                                       :mail s/Str
                                                       :password s/Str
                                                       :dob s/Str
                                                       :fullname s/Str}}
                                   :middleware [mw/add-admin-field mw/create-user]
                                   :handler auth/register}}])
