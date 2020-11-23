(ns cinemart.theaters
  (:require [cinemart.db :as db]
            [ring.util.http-response :as res]))

(defn get-theaters
  [_]
  (res/ok {:theaters (db/get-theaters db/config)}))

(defn get-theater-by-id
  [{:keys [parameters]}]
  (let [id (:path parameters)
        theater (db/get-theater-by-id db/config id)]
    (if theater
      (res/ok {:theater theater})
      (res/not-found {:error "Theater not found"}))))

(defn create-theater [{:keys [parameters]}]
  (let [theater (-> (:body parameters)
                    (partial db/insert-theater db/config)
                    (partial db/get-theater-by-id db/config))]
    (res/created
     (str "/theater/" (:id theater))
     {:theater theater})))

(defn update-theater
  [{:keys [parameters]}]
  (let [id (get-in parameters [:path :id])
        theater (assoc (:body parameters) :id id)
        updated-count (db/update-theater-by-id db/config theater)]
    (if (= 1 updated-count)
      (res/ok {:updated true
               :theater (db/get-theater-by-id db/config {:id id})})
      (res/not-found
       {:updated false
        :error "Unable to update theater"}))))

(defn delete-theater
  [{:keys [parameters]}]
  (let [id (:path parameters)
        before-deleted (db/get-theater-by-id db/config id)
        deleted-count (db/delete-theater-by-id db/config id)]
    (if (= 1 deleted-count)
      (res/ok
       {:deleted true
        :theater before-deleted})
      (res/not-found
       {:deleted false
        :error "Unable to delete theater"}))))
