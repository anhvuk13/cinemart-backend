(ns cinemart.schedules
  (:require [ring.util.http-response :as res]
            [cinemart.db :as db]))

(defn get-schedules [_]
  (res/ok {:response (db/get-schedules db/config)}))

(defn get-schedules-by-theater [{:keys [parameters]}]
  (res/ok {:response (db/get-schedules-by-theater db/config (:body parameters))}))

(defn create-schedule [{:keys [parameters]}]
  (let [data (:body parameters)
        movie (:movie data)
        theater (:theater data)]
    (if (or (empty? (db/get-theater-by-id db/config {:id theater}))
            (empty? (db/get-movie-by-id db/config {:id movie})))
      (res/not-found {:error "movie or theater invalid"})
      (let [schedule (db/insert-schedule db/config data)]
        (res/created (str "/schedules/" (:id schedule))
                     {:response schedule})))))

(defn get-schedule-by-id [{:keys [parameters]}]
  (let [id (:path parameters)
        schedule (db/get-schedule-by-id db/config id)]
    (if schedule
      (res/ok {:response schedule})
      (res/not-found {:error "schedule not found"}))))

;;(defn update-schedule [{:keys [parameters]}]
;;  (let [id (:path parameters)
;;        body (:body parameters)
;;        data (merge body id)
;;        updated-count (db/update-schedule-by-id db/config data)]
;;    (if (= 1 updated-count)
;;      (res/ok {:updated true
;;               :response (db/get-schedule-by-id db/config id)})
;;      (res/not-found {:updated false
;;                      :error "unable to update schedule"}))))

(defn delete-schedule [{:keys [parameters]}]
  (let [id (:path parameters)
        before-deleted (db/get-schedule-by-id db/config id)
        deleted-count (db/delete-schedule-by-id db/config id)]
    (println before-deleted)
    (if (= 1 deleted-count)
      (res/ok {:deleted true
               :response before-deleted})
      (res/not-found {:deleted false
                      :error "unable to delete schedule"}))))
