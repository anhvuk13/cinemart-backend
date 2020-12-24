(ns cinemart.routes
  (:require [schema.core :as s]
            [reitit.swagger :as swagger]
            [reitit.ring :as ring]
            [ring.util.http-response :as res]
            [cinemart.db :as db]
            [cinemart.middleware :as mw]
            [cinemart.auth :as auth]
            [cinemart.me :as me]
            [cinemart.persons :as persons]
            [cinemart.movies :as movies]
            [cinemart.schedules :as schedules]
            [cinemart.theaters :as theaters]
            [cinemart.invoices :as invoices]
            [cinemart.tickets :as tickets]))

(def assets-routes
  ["/assets/*" (ring/create-resource-handler)])

(defn ping-handler [req]
  (res/ok {:ping "pong"}))

(def ping-routes
  ["/ping" {:swagger {:tags ["ping"]}
            :name :ping
            :parameters {:header {(s/optional-key :authorization) s/Str}}
            :get {:summary "just ping"
                  :handler ping-handler}
            :head {:summary "login to ping"
                   :middleware [mw/token-valid mw/not-expired]
                   :handler ping-handler}
            :post {:summary "ping as user"
                   :middleware [mw/token-valid mw/not-expired [mw/roles "user"]]
                   :handler ping-handler}
            :put {:summary "ping as user or admin"
                  :middleware [mw/token-valid mw/not-expired [mw/roles "user" "admin"]]
                  :handler ping-handler}
            :delete {:summary "ping as manager"
                     :middleware [mw/token-valid mw/not-expired [mw/roles "manager"]]
                     :handler ping-handler}
            :options {:summary "ping as manager or admin"
                      :middleware [mw/token-valid mw/not-expired [mw/roles "admin" "manager"]]
                      :handler ping-handler}
            :patch {:summary "ping as admin"
                    :middleware [mw/token-valid mw/not-expired [mw/roles "admin"]]
                    :handler ping-handler}}])

(def movie-routes
  ["/movies" {:swagger {:tags ["movies"]}}
   ["" {:get movies/get-movies
        :post {:middleware [mw/movie-img [mw/ToPgJson :genres]]
               :parameters {:body {:runtime s/Int
                                   :genres [{:id s/Int
                                             :name s/Str}]
                                   :overview s/Str
                                   :title s/Str
                                   :poster_path s/Str
                                   :backdrop_path s/Str}}
               :handler movies/create-movie}
        :patch {:middleware [mw/movie-img [mw/ToPgJson :genres]]
                :parameters {:body {:id s/Int
                                    :runtime s/Int
                                    :genres [{:id s/Int
                                              :name s/Str}]
                                    :overview s/Str
                                    :title s/Str
                                    :poster_path s/Str
                                    :backdrop_path s/Str}}
                :handler movies/draw-movie}}]
   ["/latest"
    ["/from"
     ["/now" {:get movies/get-movies-from-now}]]
    ["/:count" {:parameters {:path {:count s/Int}}
                :get (fn [{:keys [parameters]}]
                       (res/ok
                         {:response
                          (db/get-latest-movies
                            db/config (:path parameters))}))}]]
   ["/genres"
    ["/one"
     ["/:id" {:parameters {:path {:id s/Int}}
              :get (fn [{:keys [parameters]}]
                     (res/ok
                       {:response
                        {:genre (db/get-genre-by-id db/config (:path parameters))
                         :movies (db/get-movies-by-genre
                                   db/config
                                   (:path parameters))}}))}]]
    ["/all" {:get (fn [_]
                    (res/ok
                      {:response
                       (db/get-genres db/config)}))}]
    ["/movies" {:get movies/get-movies-of-each-genre}]]
   ["/:id" {:parameters {:path {:id s/Int}}}
    ["" {:get movies/get-movie-by-id
         :put {:parameters {:body {(s/optional-key :runtime) s/Int
                                   (s/optional-key :genres) [{:id s/Int
                                                              :name s/Str}]
                                   (s/optional-key :overview) s/Str
                                   (s/optional-key :title) s/Str
                                   (s/optional-key :poster_path) s/Str
                                   (s/optional-key :backdrop_path) s/Str}}
               :middleware [mw/movie-img
                            [mw/draw-old-data db/get-movie-by-id]
                            [mw/ToPgJson :genres]]
               :handler movies/update-movie}
         :delete movies/delete-movie}]
    ["/screening"
     ["/theaters" {:get theaters/get-theaters-screening-this-movie}]]]])

(def theater-routes
  ["/theaters" {:swagger {:tags ["theaters"]}
                :parameters {:header {(s/optional-key :authorization) s/Str}}}
   ["" {:get {:summary "show all theater"
              :handler theaters/get-theaters}
        :post {:summary "(admin) create a new theater and its manager"
               :description "Only admins take responsibility to create a theater."
               :parameters {:body {:theater {:name s/Str
                                             :address s/Str}
                                   :manager {:mail s/Str
                                             :password s/Str}}}
               :middleware [mw/token-valid mw/not-expired [mw/roles "admin"]]
               :handler theaters/create-theater}}]
   ["/:id" {:parameters {:path {:id s/Int}}}
    ["" {:get {:summary "get details of a specific theater"
               :handler theaters/get-theater-by-id}
         :put {:summary "(admin|manager) update theater's info"
               :description "Managers who manage the current theater or any admins can update this theater info."
               :middleware [mw/token-valid mw/not-expired [mw/roles "admin" "manager"] mw/managing?]
               :parameters {:body {(s/optional-key :name) s/Str
                                   (s/optional-key :address) s/Str}}
               :handler theaters/update-theater}
         :delete {:summary "(admin) delete current theater"
                  :description "Only admins have permission to delete a theater."
                  :middleware [mw/token-valid mw/not-expired [mw/roles "admin"]]
                  :handler theaters/delete-theater}}]
    ["/movies" {:get movies/get-movies-from-now-by-theater}]
    ["/schedules"
     ["" {:get {:summary "get all schdules of an theater"
                :description "Everyone (without login) can see all schedules belong to a specific theater"
                :handler (fn [req]
                           (schedules/get-schedules-by-theater
                             (assoc-in req [:parameters :body :theater]
                                       (get-in req [:parameters :path :id]))))}
          :post {:summary "(admin|manager) create a schedules"
                 :description "Admins or managers who managing current theater can create a schedule for it."
                 :parameters {:body {:movie s/Int
                                     :room s/Int
                                     :nrow s/Int
                                     :ncolumn s/Int
                                     :price s/Int
                                     :time s/Str}}
                 :middleware [mw/token-valid mw/not-expired [mw/roles "admin" "manager"] mw/managing? [mw/StrTime? :time]]
                 :handler (fn [req]
                            (schedules/create-schedule
                              (assoc-in req [:parameters :body :theater]
                                        (get-in req [:parameters :path :id]))))}}]
     ["/:movie" {:parameters {:path {:movie s/Int}}
                 :get schedules/get-schedule-of-specific-movie-this-theater}]]
    ["/managers" {:get {:summary "(admins) get all schdules belong to a theater"
                        :description "Only admins and managers assigned can see the list of managers working at a specific theater"
                        :middleware [mw/token-valid mw/not-expired [mw/roles "admin" "manager"] mw/managing?]
                        :handler (fn [req]
                                   (persons/get-managers-by-theater
                                     (assoc-in req [:parameters :body :theater]
                                               (get-in req [:parameters :path :id]))))}}]]])

(def user-routes
  ["/users" {:middleware [mw/token-valid mw/not-expired [mw/roles "admin"]]
             :parameters {:header {(s/optional-key :authorization) s/Str}}
             :swagger {:tags ["users"]}}
   ["" {:get {:summary "(admin) get all users"
              :handler (persons/get-persons "user")}
        :post {:summary "(admin) create a new user"
               :parameters {:body {:fullname s/Str
                                   :dob s/Str
                                   :username s/Str
                                   :password s/Str
                                   :mail s/Str}}
               :middleware [[mw/StrTime? :dob] mw/create-user]
               :handler (persons/create-person "user")}}]
   ["/:id" {:parameters {:path {:id s/Int}}
            :get {:summary "(admin) get a specific user account"
                  :handler (persons/get-person-by-id "user")}
            :put {:summary "(admin) update a user account"
                  :description "You can provide all or some pairs of key:value. The missing keys will keep their old value."
                  :parameters {:body {(s/optional-key :fullname) s/Str
                                      (s/optional-key :dob) s/Str
                                      (s/optional-key :username) s/Str
                                      (s/optional-key :password) s/Str
                                      (s/optional-key :mail) s/Str}}
                  :middleware [[mw/draw-old-data db/get-user-by-id] [mw/StrTime? :dob] mw/hashpass]
                  :handler (persons/update-person "user")}
            :delete {:summary "(admin) delete a user account"
                     :handler (persons/delete-person "user")}}]])

(def manager-routes
  ["/managers" {:middleware [mw/token-valid mw/not-expired [mw/roles "admin"]]
                :parameters {:header {(s/optional-key :authorization) s/Str}}
                :swagger {:tags ["managers"]}}
   ["" {:get {:summary "(admin) get all managers"
              :handler (persons/get-persons "manager")}
        :post {:summary "(admin) create a new manager"
               :parameters {:body {:theater s/Int
                                   :mail s/Str
                                   :password s/Str}}
               :middleware [mw/create-manager]
               :handler persons/create-manager}}]
   ["/:id" {:parameters {:path {:id s/Int}}
            :get {:summary "(admin) get a specific manager account"
                  :handler (persons/get-person-by-id "manager")}
            :put {:summary "(admin) update a manager account"
                  :description "You can provide all or some pairs of key:value. The missing keys will keep their old value."
                  :parameters {:body {(s/optional-key :mail) s/Str
                                      (s/optional-key :password) s/Str}}
                  :middleware [mw/hashpass]
                  :handler (persons/update-person "manager")}
            :delete {:summary "(admin) delete a manager account"
                     :handler (persons/delete-person "manager")}}]])

(def admin-routes
  ["/admins" {:middleware [mw/token-valid mw/not-expired [mw/roles "admin"]]
              :parameters {:header {(s/optional-key :authorization) s/Str}}
              :swagger {:tags ["admins"]}}
   ["" {:get {:summary "(admin) get all admins"
              :handler (persons/get-persons "admin")}
        :post {:summary "(admin) create a new admin"
               :parameters {:body {:mail s/Str
                                   :password s/Str}}
               :middleware [mw/create-admin]
               :handler (persons/create-person "admin")}}]
   ["/:id" {:parameters {:path {:id s/Int}}
            :get {:summary "(admin) get a specific admin account"
                  :handler (persons/get-person-by-id "admin")}
            :put {:summary "(admin) update a admin account"
                  :description "You can provide all or some pairs of key:value. The missing keys will keep their old value."
                  :parameters {:body {(s/optional-key :mail) s/Str
                                      (s/optional-key :password) s/Str}}
                  :middleware [mw/hashpass]
                  :handler (persons/update-person "admin")}
            :delete {:summary "(admin) delete a admin account"
                     :handler (persons/delete-person "admin")}}]])

(def invoice-routes
  ["/invoices" {:swagger {:tags ["invoices"]}
                :middleware [mw/token-valid mw/not-expired]
                :parameters {:header {(s/optional-key :authorization) s/Str}}}
   ["" {:middleware [[mw/roles "admin"]]
        :get {:summary "(admin) get all invoices"
              :handler invoices/get-invoices}
        :post {:summary "(admin) create an invoice"
               :parameters {:body {:schedule s/Int
                                   :user s/Int
                                   :booked_seats [s/Int]
                                   :seats_name [s/Str]}}
               :handler invoices/create-invoices}}]
   ["/:id" {:get {:summary "(admin) get a specific invoice"
                  :middleware [[mw/roles "admin"]]
                  :parameters {:path {:id s/Int}}
                  :handler invoices/get-invoice-by-id}
            :delete {:summary "(user|admin) delete an invoice"
                     :middleware [[mw/roles "admin" "user"] mw/user-own-invoice?]
                     :parameters {:path {:id s/Int}}
                     :handler invoices/delete-invoces}}]])

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
  ["/schedules" {:swagger {:tags ["schedules"]}
                 :parameters {:header {(s/optional-key :authorization) s/Str}}}
   ["" {:get {:summary "get all schedules"
              :handler schedules/get-schedules}
        :post {:summary "(admin) create a schedules"
               :parameters {:body {:movie s/Int
                                   :theater s/Int
                                   :room s/Int
                                   :nrow s/Int
                                   :ncolumn s/Int
                                   :price s/Int
                                   :time s/Str}}
               :middleware [mw/token-valid mw/not-expired [mw/roles "admin"] [mw/StrTime? :time]]
               :handler schedules/create-schedule}}]
   ["/current"
    ["/day" {:get {:summary "get schedules of this day"
                   :handler schedules/get-schedules-by-date}}]
    ["/week" {:get {:summary "get schedules of this week"
                    :handler schedules/get-schedules-by-week}}]]
   ["/:id" {:parameters {:path {:id s/Int}}}
    ["" {:get {:summary "get a specific schedule"
               :handler schedules/get-schedule-by-id}
         :delete {:summary "(admin) delete a schdule"
                  :middleware [mw/token-valid mw/not-expired [mw/roles "admin"]]
                  :handler schedules/delete-schedule}}]
    ["/reserved-seats" {:get
                        (fn [req]
                          (res/ok
                            {:response
                             (cinemart.db/get-reserved-seats-of-schedule
                               cinemart.db/config
                               {:schedule (get-in req [:parameters :path :id])})}))}]]])

(def me-routes ["/me" {:swagger {:tags ["me"]}
                       :parameters {:header {(s/optional-key :authorization) s/Str}}
                       :middleware [mw/token-valid mw/not-expired]}
                ["" {:get {:summary "(login) get your profile"
                           :handler me/get-my-info}
                     :delete {:summary "(login) delete your profile"
                              :handler me/delete-my-account}
                     :put {:summary "(login) update your account info"
                           :description "Provide which key:value pairs need to be changed. The current pair of tokens will also be renewed."
                           :parameters {:body {(s/optional-key :fullname) s/Str
                                               (s/optional-key :username) s/Str
                                               (s/optional-key :mail) s/Str
                                               (s/optional-key :password) s/Str
                                               (s/optional-key :dob) s/Str}}
                           :middleware [mw/hashpass]
                           :handler me/update-my-info}}]
                ["/invoices" {:middleware [[mw/roles "user"]]
                              :get {:summary "(user) get my invoices"
                                    :handler invoices/get-my-invoices}
                              :post {:summary "(user) book tickets"
                                     :parameters {:body {:user s/Int
                                                         :schedule s/Int
                                                         :booked_seats [s/Int]
                                                         :seats_name [s/Str]}}
                                     :handler (fn [req]
                                                (invoices/create-invoices
                                                  (assoc-in
                                                    req
                                                    [:parameters :body :user]
                                                    (get-in req [:info :id]))))}}]])

(def refresh-token ["/refresh-token" {:summary "acquire new pair of tokens"
                                      :swagger {:tags ["auth"]}
                                      :parameters {:header {(s/optional-key :authorization) s/Str}}
                                      :post {:middleware [mw/rtoken-valid mw/not-expired]
                                             :handler auth/refresh}}])

(def login ["/login" {:swagger {:tags ["auth"]}
                      :parameters {:body {:mail s/Str
                                          :password s/Str}}}
            ["" {:summary "login user account"
                 :post (fn [req]
                         (auth/login req "user"))}]
            ["/manager" {:summary "login manager account"
                         :post (fn [req]
                                 (auth/login req "manager"))}]
            ["/admin" {:summary "login admin account"
                       :post (fn [req]
                               (auth/login req "admin"))}]])

(def logout ["/logout" {:swagger {:tags ["auth"]}
                        :parameters {:header {(s/optional-key :authorization) s/Str}}
                        :middleware [mw/token-valid]}
             ["" {:summary "logout & revoke current being used pair of tokens"
                  :post auth/logout}]
             ["/other-devices" {:summary "revoke all other pairs of tokens bound to current user except the one being used"
                                :middleware [mw/not-expired]
                                :post auth/logout-from-other-devices}]])

(def register ["/register" {:swagger {:tags ["auth"]}
                            :summary "register a new user account"
                            :post {:parameters {:body {:username s/Str
                                                       :mail s/Str
                                                       :password s/Str
                                                       :dob s/Str
                                                       :fullname s/Str}}
                                   :middleware [[mw/StrTime? :dob] mw/create-user mw/hashpass]
                                   :handler (fn [req]
                                              (auth/register req "user"))}}])
