(ns cinemart.theaters
  (:require [buddy.hashers :as h]
            [cinemart.db :as db]
            [ring.util.http-response :as res]))

(defn get-theaters
  [{:keys [parameters]}]
  (res/ok {:response (db/get-theaters db/config)}))

(defn get-theater-by-id
  [{:keys [parameters]}]
  (let [id (:path parameters)
        theater (db/get-theater-by-id db/config id)]
    (if theater
      (res/ok {:response theater})
      (res/not-found {:error "Theater not found"}))))

(defn get-theaters-screening-this-movie [{:keys [parameters]}]
  (res/ok {:response (db/get-theaters-by-movie db/config (:path parameters))}))

(defn create-theater [{:keys [parameters]}]
  (let [theater-info (get-in parameters [:body :theater])
        temp (get-in parameters [:body :manager])
        manager-info (assoc temp :password (h/derive (:password temp)))]
    (if (db/get-manager-by-mail db/config manager-info)
      (res/bad-request {:error "manager mail is used already"})
      (let [theater (db/insert-theater db/config theater-info)
            manager (->
                      (db/insert-manager db/config manager-info)
                      (assoc :theater_name (:name theater))
                      (dissoc :password))
            management (db/insert-management db/config
                                             {:theater (:id theater)
                                              :manager (:id manager)})]
        (res/created
         (str "/theater/" (:id theater))
         {:response {:theater theater
                     :manager manager
                     :management management}})))))

(comment
  (create-theater {:parameters {:header "eyJhbGciOiJIUzI1NiJ9.eyJpZCI6MywicGFzc3dvcmQiOiJiY3J5cHQrc2hhNTEyJDViNmEyNjc5ZGVhMzAyNDdkZmUyNGFkYTlhMDdhMTdkJDEyJDhiMDg2OTM2OGRjZTYwNWM1NjZlZjJkZjMxYjQ3MDMyMWFjMDJiZGUyM2QwNzQ3YiIsIm1haWwiOiJhZG1pbkBjaW5lbWFydC5jb20iLCJjcmVhdGVkX2F0IjoxNjA2NjQ4MTQ0LCJyb2xlIjoiYWRtaW4iLCJleHBpcmUiOjE2MDY5MTg1NTg1MDksImV4cCI6MTYwNjkxODU1ODUxMH0.4eb38YI22DGaRSypwsF-YNEhhTMESX74t-IKcGF19HM"
                                :body {:theater
                                       {:name "string"
                                        :address "string"}
                                       :manager
                                       {:mail "string"
                                        :password "string"}}}}))

(defn update-theater
  [{:keys [parameters]}]
  (let [id (:path parameters)
        old-data (db/get-theater-by-id db/config id)
        theater (merge old-data (:body parameters))
        updated-count (db/update-theater-by-id db/config theater)]
    (if (= 1 updated-count)
      (res/ok {:updated true
               :response {:before-updated old-data
                          :after-updated theater}})
      (res/not-found
       {:updated false
        :error "Unable to update theater"}))))

(comment
  (update-theater {:parameters {:path {:id 1}
                                :body {:name "s"}
                                :header "eyJhbGciOiJIUzI1NiJ9.eyJpZCI6MywicGFzc3dvcmQiOiJiY3J5cHQrc2hhNTEyJDViNmEyNjc5ZGVhMzAyNDdkZmUyNGFkYTlhMDdhMTdkJDEyJDhiMDg2OTM2OGRjZTYwNWM1NjZlZjJkZjMxYjQ3MDMyMWFjMDJiZGUyM2QwNzQ3YiIsIm1haWwiOiJhZG1pbkBjaW5lbWFydC5jb20iLCJjcmVhdGVkX2F0IjoxNjA2NjQ4MTQ0LCJyb2xlIjoiYWRtaW4iLCJleHBpcmUiOjE2MDY5MTkxOTg2MTMsImV4cCI6MTYwNjkxOTE5ODYxNH0.2e1nnOcS_b6coNNvjZtAz3_kEHiSoxUhYeMlMv67E9w"}}))

(defn delete-theater
  [{:keys [parameters]}]
  (let [id (:path parameters)
        before-deleted (db/get-theater-by-id db/config id)
        deleted-count (db/delete-theater-by-id db/config id)]
    (if (= 1 deleted-count)
      (res/ok
       {:deleted true
        :response {:before-deleted before-deleted}})
      (res/not-found
       {:deleted false
        :error "Unable to delete theater"}))))
