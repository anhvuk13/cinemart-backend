(ns cinemart.schedules
  (:require [cinemart.db :as db]))

(defn get-schedules
  [_]
  {:status 200
   :body (db/get-schedules db/config)})

(defn create-schedule
  [{:keys [parameters]}]
  (let [data (:body parameters)
        created-id (db/insert-schedule db/config data)]
    {:status 201
     :body (db/get-schedule-by-id db/config created-id)}))

(defn get-schedule-by-id
  [{:keys [parameters]}]
  (let [id (:path parameters)
        schedule (db/get-schedule-by-id db/config id)]
    (if schedule
      {:status 200
       :body schedule}
      {:status 404
       :body {:error "Schedule not found"}})))

(defn update-schedule
  [{:keys [parameters]}]
  (let [id (get-in parameters [:path :id])
        body (:body parameters)
        data (assoc body :id id)
        updated-count (db/update-schedule-by-id db/config data)]
    (if (= 1 updated-count)
      {:status 200
       :body {:updated true
              :schedule (db/get-schedule-by-id db/config {:id id})}}
      {:status 404
       :body {:updated false
              :error "Unable to update schedule"}})))

(defn delete-schedule
  [{:keys [parameters]}]
  (let [id (:path parameters)
        before-deleted (db/get-schedule-by-id db/config id)
        deleted-count (db/delete-schedule-by-id db/config id)]
    (if (= 1 deleted-count)
      {:status 200
       :body {:deleted true
              :schedule before-deleted}}
      {:status 404
       :body {:deleted false
              :error "Unable to delete schedule"}})))
