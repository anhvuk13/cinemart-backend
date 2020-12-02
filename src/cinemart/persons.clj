(ns cinemart.persons
  (:require [cinemart.db :as db]
            [cinemart.services :as s]
            [ring.util.http-response :as res]))

(defn get-persons [role]
  (fn [req]
    (let [[get-db-many] (s/get-many-func-by-role role)]
      (res/ok {(keyword (str role "s")) (get-db-many db/config)}))))

(defn create-person [role]
  (fn [{:keys [parameters]}]
    (let [[get-db _ _] (s/get-func-by-role role)
          [insert-db] (s/insert-func-by-role role)
          data (:body parameters)
          account (-> data
                      (s/hashpass)
                      ((partial insert-db db/config))
                      ((partial get-db db/config))
                      (dissoc :password))]
      (res/created
       (str "/" role "/" (:id account))
       {:inserted account}))))

(defn get-person-by-id [role]
  (fn [{:keys [parameters]}]
    (let [id (:path parameters)
          [get-db _ _] (s/get-func-by-role role)
          account (get-db db/config id)]
      (if account
        (res/ok {(keyword role) account})
        (res/not-found {:error (str role " not found")})))))

(defn update-person [role]
  (fn [{:keys [parameters]}]
    (let [id (:path parameters)
          [get-db update-db _] (s/get-func-by-role role)
          old-data (get-db db/config id)
          account (merge old-data (:body parameters) id)
          updated-count (update-db db/config account)]
      (if (= 1 updated-count)
        (do
          (s/revoke-all-tokens id role [])
          (res/ok {:updated true
                   :before-updated old-data
                   :after-updated (get-db db/config id)}))
        (res/not-found
         {:updated false
          :error (str "unable to update " role)})))))

(defn delete-person [role]
  (fn [{:keys [parameters]}]
    (let [id (:path parameters)
          [get-db _ delete-db] (s/get-func-by-role role)
          before-deleted (get-db db/config id)
          deleted-count (delete-db db/config id)]
      (if (= 1 deleted-count)
        (res/ok
         {:deleted true
          :before-deleted before-deleted})
        (res/not-found
         {:deleted false
          :error (str "unable to delete " role)})))))
