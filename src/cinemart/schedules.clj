(ns cinemart.schedules
  (:require [ring.util.http-response :as res]
            [clj-time.core :as t]
            [clj-time.format :as f]
            [cinemart.db :as db]))

(defn get-schedules [_]
  (res/ok {:response (db/get-schedules db/config)}))

(defn get-schedules-by-date [_]
  (let [now (t/now)
        year (t/year now)
        month (t/month now)
        week (t/week-number-of-year now)
        day (t/day now)]
    (res/ok {:response (db/get-schedules-by-date
                         db/config
                         {:year year
                          :month month
                          :week week
                          :day day})})))

(defn get-schedules-by-week [_]
  (let [now (t/now)
        year (t/year now)
        month (t/month now)
        week (t/week-number-of-year now)]
    (res/ok {:response (db/get-schedules-by-week
                         db/config
                         {:year year
                          :month month
                          :week week})})))

(defn get-schedules-by-theater [{:keys [parameters]}]
  (let [theater (get-in parameters [:body :theater])
        now (t/now)
        year (t/year now)
        month (t/month now)
        week (t/week-number-of-year now)
        day (t/day now)
        all (db/get-schedules-by-theater db/config {:theater theater})
        by-week (filter (fn [schedule]
                          (let [time (f/parse (:time schedule))]
                            (and (= year (t/year time))
                                 (= month (t/month time))
                                 (= week (t/week-number-of-year time)))))
                        all)
        by-day (filter (fn [schedule]
                         (let [time (f/parse (:time schedule))]
                           (= day (t/day time))))
                       by-week)]
    (res/ok {:response {:all all
                        :week by-week
                        :day by-day}})))

(defn get-schedule-of-specific-movie-this-theater [{:keys [parameters]}]
  (res/ok
    {:response (db/get-schedules-by-theater-and-movie db/config (:path parameters))}))

(defn create-schedule [{:keys [parameters]}]
  (let [data (:body parameters)
        movie (:movie data)
        theater (:theater data)]
    (if (or (empty? (db/get-theater-by-id db/config {:id theater}))
            (empty? (db/get-movie-by-id db/config {:id movie})))
      (res/not-found {:error "movie or theater invalid"})
      (let [schedule (db/insert-schedule db/config data)]
        (res/created (str "/schedules/" (:id schedule))
                     {:response (db/get-schedule-by-id db/config schedule)})))))

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
