(ns cinemart.routes
  (:require [schema.core :as s]
            [cinemart.contacts :refer [get-contacts
                                       create-contact
                                       get-contact-by-id
                                       update-contact
                                       delete-contact]]
            [cinemart.users :refer [get-user-by-id]]))
(def ping-routes
  ["/ping" {:name :ping
            :get (fn [_]
                   {:status 200
                    :body {:ping "pong"}})}])
(comment
  (def user-routes
    ["/users"
     ["" {:get get-users
          :post {:parameters {:body {;TODO
                                     }}
                 :handler create-user}}]
     ["/:id" {:get get-user-by-id
              :put {:parameters {:body {;TODO
                                        }}
                    :handler update-user}
              :delete delete-user}]]))
(comment
  (def schedule-routes
    ["/schedules"
     ["" {:get get-schedules
          :post {:parameters {:body {;TODO
                                     }}
                 :handler create-schedule}}]
     ["/:id" {:get get-schedule-by-id
              :put {:parameters {:body {;TODO
                                        }}
                    :handler update-schedule}
              :delete delete-schedule}]]))

(def contact-routes
  ["/contacts"
   ["" {:get get-contacts
        :post {:parameters {:body {:first-name s/Str
                                   :last-name s/Str
                                   :email s/Str}}
               :handler create-contact}}]
   ["/:id" {:parameters {:path {:id s/Int}}
            :get get-contact-by-id
            :put {:parameters {:body {:first-name s/Str
                                      :last-name s/Str
                                      :email s/Str}}
                  :handler update-contact}
            :delete delete-contact}]])
