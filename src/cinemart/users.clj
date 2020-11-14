(ns cinemart.users
  (:require [cinemart.db :as db]
            [buddy.hashers :as h]
            [ring.util.http-response :as res]))

(defn get-users
  [_]
  (res/ok {:users (db/get-users db/config)}))

(defn create-user [{:keys [parameters]}]
  (let [data (:body parameters)
        user (-> data
                 (assoc :password
                        (h/derive (:password data)))
                 ((partial db/insert-user db/config))
                 ((partial db/get-user-by-id db/config)))]
    (res/created
     (str "/user/" (:id user))
     {:user user})))

(comment
  (create-user
   {:parameters {:body {:username "johndoe"
                        :mail "john@doe.com"
                        :fullname "John Doe"
                        :dob "1/1/1"
                        :password "password"}}}))

(defn get-user-by-id
  [{:keys [parameters]}]
  (let [id (:path parameters)
        user (db/get-user-by-id db/config id)]
    (if user
      (res/ok {:user user})
      (res/not-found {:error "User not found"}))))

(defn update-user
  [{:keys [parameters]}]
  (let [id (get-in parameters [:path :id])
        user (assoc (:body parameters) :id id)
        updated-count (db/update-user-by-id db/config user)]
    (if (= 1 updated-count)
      (res/ok {:updated true
               :user (db/get-user-by-id db/config {:id id})})
      (res/not-found
       {:updated false
        :error "Unable to update user"}))))

(defn delete-user
  [{:keys [parameters]}]
  (let [id (:path parameters)
        before-deleted (db/get-user-by-id db/config id)
        deleted-count (db/delete-user-by-id db/config id)]
    (if (= 1 deleted-count)
      (res/ok
       {:deleted true
        :user before-deleted})
      (res/not-found
       {:deleted false
        :error "Unable to delete user"}))))
