(ns cinemart.persons
  (:require [cinemart.db :as db]
            [cinemart.services :as s]
            [ring.util.http-response :as res]))

(defn get-persons [role]
  (fn [req]
    (let [[get-db-many] (s/get-many-func-by-role role)]
      (res/ok {:response (get-db-many db/config)}))))

(defn create-person [role]
  (fn [{:keys [parameters]}]
    (let [[insert-db] (s/insert-func-by-role role)
          data (:body parameters)
          account (-> data
                      (s/hashpass)
                      ((partial insert-db db/config))
                      (dissoc :password))]
      (res/created
        (str "/" role "s/" (:id account))
        {:response account}))))

(comment
  ((create-person "manager")
   {:parameters {:body {:theater 5
                        :mail "alohihi"
                        :password "string"}}}))

(defn get-person-by-id [role]
  (fn [{:keys [parameters]}]
    (let [id (:path parameters)
          [get-db _ _] (s/get-func-by-role role)
          account (get-db db/config id)]
      (if account
        (res/ok {:response account})
        (res/not-found {:error (str role " not found")})))))

(defn update-person [role]
  (fn [{:keys [parameters]}]
    (let [id (:path parameters)
          [get-db update-db _] (s/get-func-by-role role)
          old-data (get-db db/config id)
          account (merge old-data (:body parameters) id)
          updated-count (update-db db/config account)
          after-updated (get-db db/config id)]
      (if (= 1 updated-count)
        (do
          (s/revoke-all-tokens id role [])
          (res/ok {:updated true
                   :response {:before-updated (dissoc old-data :password)
                              :after-updated (dissoc after-updated :password)}}))
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
        (do
          (s/revoke-all-tokens id role [])
          (res/ok
            {:deleted true
             :response {:before-deleted before-deleted}}))
        (res/not-found
          {:deleted false
           :error (str "unable to delete " role)})))))

(defn create-manager [{:keys [parameters]}]
  (let [data (:body parameters)
        account (-> data
                    (s/hashpass)
                    ((partial db/insert-manager db/config))
                    (dissoc :password))
        theater_name (:name (db/get-theater-by-id db/config {:id (:theater data)}))]
    (db/insert-management db/config
                          {:theater (:theater data)
                           :manager (:id account)})
    (res/created
      (str "/managers/" (:id account))
      {:response (assoc account :theater_name theater_name)})))

(defn get-managers-by-theater [{:keys [parameters]}]
  (res/ok {:response (db/get-managers-by-theater db/config (:body parameters))}))
