(ns cinemart.middleware
  (:require
   [buddy.auth :refer [authenticated?]]
   [buddy.auth.middleware :refer [wrap-authentication]]
   [cinemart.auth :as auth]))

(defn login-auth
  [handler]
  (wrap-authentication handler auth/login))

(defn auth?
  [handler]
  (fn [request]
    (if (authenticated? request)
      (handler request)
      {:body {:status 401
              :error "Not Authorized"}})))






