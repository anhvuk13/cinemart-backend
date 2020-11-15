(ns cinemart.core
  (:require [org.httpkit.server :refer [run-server]]
            [ring.util.http-response :as res]
            [reitit.ring :as ring]
            [reitit.swagger :as swagger]
            [reitit.swagger-ui :as swagger-ui]
            [ring.middleware.cors :refer [wrap-cors]]
            [reitit.ring.middleware.exception
             :refer [exception-middleware]]
            [reitit.ring.middleware.parameters
             :refer [parameters-middleware]]
            [reitit.ring.middleware.muuntaja
             :refer [format-negotiate-middleware
                     format-request-middleware
                     format-response-middleware]]
            [reitit.ring.coercion
             :refer [coerce-exceptions-middleware
                     coerce-request-middleware
                     coerce-response-middleware]]
            [reitit.coercion.schema]
            [muuntaja.core :as m]
            [cinemart.routes :as r]))

(defonce server (atom nil))

(def app
  (ring/ring-handler
   (ring/router
    [["/swagger.json"
      {:get {:no-doc true
             :swagger {:info {:title "cinemart-api"}
                       :basePath "/"} ;; prefix for all paths
             :handler (swagger/create-swagger-handler)}}]
     [     r/ping-routes
r/login
     r/register
     r/token
     r/user-routes
     r/schedule-routes
     r/ticket-routes
     ]
    {:data {:coercion reitit.coercion.schema/coercion
            :muuntaja m/instance
            :middleware [[wrap-cors
                          :access-control-allow-origin [#"http://localhost:4200"]
                          :access-control-allow-methods [:get :post :put :delete]]
                         parameters-middleware
                         format-negotiate-middleware
                         format-response-middleware
                         exception-middleware
                         format-request-middleware
                         coerce-exceptions-middleware
                         coerce-request-middleware
                         coerce-response-middleware]}})
   (ring/routes
    (swagger-ui/create-swagger-ui-handler {:path "/"})
    (ring/redirect-trailing-slash-handler)
    (ring/create-default-handler
     {:not-found (constantly (res/not-found {:error "Route not found"}))}))))

(defn stop-server []
  (when-not (nil? @server)
    (@server :timeout 100)
    (reset! server nil)))

(defn -main []
  (println "Server started")
  (reset! server (run-server app {:port 4000})))

(defn restart-server []
  (stop-server)
  (-main))

(comment
  (app {:request-method :get
        :uri "/api/ping"})
  (app {:request-method :get
        :uri "/api/invalid"})
  (app {:request-method :get
        :uri "/api/contacts"})
  (app {:request-method :delete
        :uri "/api/contacts/3"})
  (app {:request-method :post
        :uri "/api/contacts/"
        :body "{\"first-name\":\"Kelvin\",\"last-name\":\"Mai\",\"email\":\"kelvin.mai002@gmail.com\"}"})
  (restart-server))
