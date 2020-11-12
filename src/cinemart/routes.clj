(ns cinemart.routes
  (:require [schema.core :as s]
            [cinemart.contacts :refer [get-contacts
                                       create-contact
                                       get-contact-by-id
                                       update-contact
                                       delete-contact]]
            [cinemart.users :refer [get-users
                                    create-user
                                    get-user-by-id
                                    update-user
                                    delete-user]]
            [cinemart.schedules :refer [get-schedules
                                        create-schedule
                                        get-schedule-by-id
                                        update-schedule
                                        delete-schedule]]
            [cinemart.tickets :refer [get-tickets
                                      create-ticket
                                      get-ticket-by-id
                                      update-ticket
                                      delete-ticket]]))

(def ping-routes
  ["/ping" {:name :ping
            :get (fn [_]
                   {:status 200
                    :body {:ping "pong"}})}])

(def user-routes
  ["/users"
   ["" {:get get-users
        :post {:parameters {:body {:fullname s/Str
                                   :dob s/Str
                                   :username s/Str
                                   :password s/Str
                                   :mail s/Str}}
               :handler create-user}}]
   ["/:id" {:parameters {:path {:id s/Int}}
            :get get-user-by-id
            :put {:parameters {:body {:fullname s/Str
                                      :dob s/Str
                                      :gender s/Str
                                      :mail s/Str}}
                  :handler update-user}
            :delete delete-user}]])

(def ticket-routes
  ["/tickets"
   ["" {:get get-tickets
        :post {:parameters {:body {:user-id s/Int
                                   :schedule-id s/Int
                                   :seat s/Int}}
               :handler create-ticket}}]
   ["/:id" {:get get-ticket-by-id
            :put {:parameters {:body {:user-id s/Int
                                      :schedule-id s/Int
                                      :seat s/Int}}
                  :handler update-ticket}
            :delete delete-ticket}]])

(def schedule-routes
  ["/schedules"
   ["" {:get get-schedules
        :post {:parameters {:body {:film s/Str
                                   :room s/Str
                                   :time s/Str
                                   :seats s/Int}}
               :handler create-schedule}}]
   ["/:id" {:get get-schedule-by-id
            :put {:parameters {:body {:film s/Str
                                      :room s/Str
                                      :time s/Str}}
                  :handler update-schedule}
            :delete delete-schedule}]])

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
