(ns cinemart.users
  (:require [cinemart.db :as db]
            [buddy.hashers :as hasher]))

(defn get-users
  [_]
  {:status 200
   :body (db/get-users db/config)})

(defn create-user
  [{:keys [parameters]}]
  (let [data (:body parameters)
        pw (hasher/derive (:password data))
        created-id (db/insert-user db/config (assoc data :password pw))]
    {:status 201
     :body (db/get-user-by-id db/config created-id)}))

(defn get-user-by-id
  [{:keys [parameters]}]
  (let [id (:path parameters)
        user (db/get-user-by-id db/config id)]
    (if user
      {:status 200
       :body user}
      {:status 404
       :body {:error "User not found"}})))

(defn update-user
  [{:keys [parameters]}]
  (let [id (get-in parameters [:path :id])
        body (:body parameters)
        data (assoc body :id id)
        updated-count (db/update-user-by-id db/config data)]
    (if (= 1 updated-count)
      {:status 200
       :body {:updated true
              :user (db/get-user-by-id db/config {:id id})}}
      {:status 404
       :body {:updated false
              :error "Unable to update user"}})))

(defn delete-user
  [{:keys [parameters]}]
  (let [id (:path parameters)
        before-deleted (db/get-user-by-id db/config id)
        deleted-count (db/delete-user-by-id db/config id)]
    (if (= 1 deleted-count)
      {:status 200
       :body {:deleted true
              :user before-deleted}}
      {:status 404
       :body {:deleted false
              :error "Unable to delete user"}})))
