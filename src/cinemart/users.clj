(ns cinemart.users
  (:require [cinemart.db :as db]))

(defn get-user-by-id
  [_]
  {:status 200
   :body (db/get-users db/config)})
