(ns cinemart.me
  (:require [ring.util.http-response :as res]
            [cinemart.db :as db]
            [cinemart.services :as s]))

(defn get-my-info [req]
  (let [token (:token (db/get-auth-by-token
                       db/config {:token (s/strip-token req)}))]
    (if token
      (res/ok {:me (-> (s/decreate-token token)
                       (dissoc :password :expire :exp))})
      (res/not-found {:error "token invalid"}))))

(defn update-my-info [req]
  (let [token (s/strip-token req)
        me (-> (s/decreate-token token)
               (dissoc :password :expire :exp))
        role (:role me)
        id (:id me)
        [get-db update-db _] (s/get-func-by-role role)
        update-data (get-in req [:parameters :body])
        updated-data (merge me update-data)
        updated-count (update-db db/config updated-data)]
    (if (= 1 updated-count)
      (do
        (db/delete-auth-by-token db/config {:token token})
        (res/ok {:updated true
                 :me (s/add-token updated-data role)}))
      (res/not-found {:updated false
                      :error (str "Unable to update " role)}))))

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
