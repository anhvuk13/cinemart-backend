(ns cinemart.tickets
  (:require [cinemart.db :as db]))

(defn get-tickets
  [_]
  {:status 200
   :body (db/get-tickets db/config)})

(defn create-ticket
  [{:keys [parameters]}]
  (let [data (:body parameters)
        created-id (db/insert-ticket db/config data)]
    {:status 201
     :body (db/get-ticket-by-id db/config created-id)}))

(defn get-ticket-by-id
  [{:keys [parameters]}]
  (let [id (:path parameters)
        ticket (db/get-ticket-by-id db/config id)]
    (if ticket
      {:status 200
       :body ticket}
      {:status 404
       :body {:error "Ticket not found"}})))

(defn update-ticket
  [{:keys [parameters]}]
  (let [id (get-in parameters [:path :id])
        body (:body parameters)
        data (assoc body :id id)
        updated-count (db/update-ticket-by-id db/config data)]
    (if (= 1 updated-count)
      {:status 200
       :body {:updated true
              :ticket (db/get-ticket-by-id db/config {:id id})}}
      {:status 404
       :body {:updated false
              :error "Unable to update ticket"}})))

(defn delete-ticket
  [{:keys [parameters]}]
  (let [id (:path parameters)
        before-deleted (db/get-ticket-by-id db/config id)
        deleted-count (db/delete-ticket-by-id db/config id)]
    (if (= 1 deleted-count)
      {:status 200
       :body {:deleted true
              :ticket before-deleted}}
      {:status 404
       :body {:deleted false
              :error "Unable to delete ticket"}})))
