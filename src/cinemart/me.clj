(ns cinemart.me
  (:require [ring.util.http-response :as res]
            [clj-time.format :as f]
            [cinemart.db :as db]
            [cinemart.services :as s]))

(defn get-my-info [{:keys [info]}]
  (res/ok {:response info}))

(defn update-my-info [req]
  (let [token (:token req)
        me (:info req)
        role (:role me)
        id (:id me)
        [get-db update-db _] (s/get-func-by-role role)
        old-data (get-db db/config me)
        update-data (get-in req [:parameters :body])
        data (merge old-data update-data)
        ca (f/parse (:created_at data))
        dob (f/parse (:dob data))
        updated-data (assoc data :created_at ca :dob dob)
        updated-count (update-db db/config updated-data)
        new-data (get-db db/config {:id id})]
    (if (= 1 updated-count)
      (do
        (s/revoke-all-tokens id role [])
        (res/ok {:updated true
                 :response (s/add-token req new-data role)}))
      (res/not-found {:updated false
                      :error (str "Unable to update " role)}))))

(defn delete-my-account [{:keys [token info]}]
  (let [id (:id info)
        role (:role info)
        [get-db _ delete-db] (s/get-func-by-role role)
        account (get-db db/config {:id id})]
    (delete-db db/config {:id id})
    (db/delete-auth-by-token db/config {:token token})
    (res/ok {:message "deleted"
             :response account})))

(comment
  (def req
    {:parameters
     {:body {:fullname "string"
             :username "string"
             :password (s/hashpass "password")
             :mail "string"
             :dob "string"}}
     :headers {"authorization" "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoidXNlciIsInBhc3N3b3JkIjoiYmNyeXB0K3NoYTUxMiRlYmNmZDM2NTM3MWFkNTA2M2IxZmI3NDQxZmY4MWNkYyQxMiRhNjg0MWRjNGNjM2MzNTVjYjVjNzIwZTZiNTRlM2RjYzhjYTQ4ZmM4YWI5YzM2MjkiLCJtYWlsIjoic3RyaW5nIiwiZXhwIjoxNjA2NDQyNzUzODU1LCJ1c2VybmFtZSI6InN0cmluZyIsImZ1bGxuYW1lIjoic3RyaW5nIiwiZXhwaXJlIjoxNjA2NDQyNzUzODU0LCJkb2IiOiJzdHJpbmciLCJpZCI6MTQsImNyZWF0ZWRfYXQiOjE2MDYzODI3NTN9.5mpBm6-FZdqoLM550Bsw93gXQ2lj_q715jbnRnHRMcQ"}})

  (get-my-info req)
  (update-my-info req))
