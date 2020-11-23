(ns cinemart.tickets
  (:require [ring.util.http-response :as res]
            [cinemart.db :as db]))

(defn get-tickets
  [_]
  (res/ok (db/get-tickets db/config)))

(defn get-seats-of-invoice
  [{:keys [parameters]}]
  (let [data (:body parameters)]
    (res/ok
     {:seats (db/get-seats-of-invoice db/config)})))

(defn create-ticket
  [{:keys [parameters]}]
  (let [data (:body parameters)
        created (db/insert-ticket db/config data)]
    {:status 201
     :body (db/get-ticket-by-invoice-and-seat
            db/config created)}))

(defn delete-ticket
  [{:keys [parameters]}]
  (let [data (:body parameters)
        before-deleted (db/get-ticket-by-invoice-and-seat
                        db/config data)
        deleted-count (db/delete-ticket-by-invoice-and-seat
                       db/config data)]
    (if (= 1 deleted-count)
      {:status 200
       :body {:deleted true
              :ticket before-deleted}}
      {:status 404
       :body {:deleted false
              :error "Unable to delete ticket"}})))
