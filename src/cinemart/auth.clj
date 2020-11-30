(ns cinemart.auth
  (:require [ring.util.http-response :as res]
            [cinemart.db :as db]
            [cinemart.services :as s]))

(defn refresh [{:keys [token info]}]
  (db/delete-auth-by-refresh-token db/config
                                   {:refresh-token token})
  (res/ok {:user
           (s/add-token info (:role info))}))

(defn register [{:keys [parameters]}, role]
  (let [data (:body parameters)
        user (-> data
                 ((partial db/insert-user db/config))
                 ((partial db/get-user-by-id db/config))
                 (s/add-token role))]
    (res/created
     (str "/user/" (:id user))
     {:user user})))

(defn login [{:keys [parameters]} role]
  (let [mail (get-in parameters [:body :mail])
        user (db/get-user-by-mail db/config {:mail mail})
        password (get-in parameters [:body :password])]
    (if user
      (if (try (s/checkpass password user)
               (catch Exception e false))
        (res/ok {:user (s/add-token user role)})
        (res/unauthorized {:error "Wrong password"}))
      (res/not-found {:error "User not found"}))))

;; log out from other device

(defn delete-other-tokens-bound-to-user
  (;; delete all other tokens
   [info current-token]
   (delete-other-tokens-bound-to-user info current-token (fn [_] true)))
  (;; delete other tokens with additional condition (check)
   [{:keys [role id]} current-token check]
   (doseq [t (db/get-auth db/config)]
     (let [token (:token t)
           info (s/decreate-token token)
           info-id (:id info)
           info-role (:role info)]
       (if (or (not info)
               (and (= id info-id)
                    (= role info-role)
                    (not= token current-token)
                    (check t)))
         (db/delete-auth-by-token db/config {:token token}))))))

(defn logout-from-other-devices [{:keys [token info]}]
  (delete-other-tokens-bound-to-user info token)
  (res/ok {:message "Logged out from all other devices"}))

;; log out from current token

(defn delete-other-tokens-bound-to-user-if-expired [info current-token]
  (delete-other-tokens-bound-to-user info current-token
                                     #(s/dead? (:refresh_token %))))

(comment (def tok "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoidXNlciIsInBhc3N3b3JkIjoiYmNyeXB0K3NoYTUxMiRmMTJhMTY1ODkzZjg4OTJhMGFlMmQ2YjQyYTM4OGY0ZSQxMiRiZDA5Mzk0M2RjN2MyNjA4YmIzMjJkMjc3OWY2MDkzNGYzNGZkMThjMGU3ODY2ODQiLCJtYWlsIjoic3RyaW5nIiwiZXhwIjoxNjA2NDAzMDQ1NzQ4LCJ1c2VybmFtZSI6InN0cmluZyIsImZ1bGxuYW1lIjoic3RyaW5nIiwiZXhwaXJlIjoxNjA2NDAzMDQ1NzQ3LCJkb2IiOiJzdHJpbmciLCJpZCI6MTksImNyZWF0ZWRfYXQiOjE2MDYzOTk4ODB9.HJlhhL0KCsJKTATK_dT4OhEpAUeAYLckbhrd0Epv8A8")
         (delete-other-tokens-bound-to-user-if-expired
          (s/decreate-token tok) tok))

(defn logout [{:keys [token info]}]
  (delete-other-tokens-bound-to-user-if-expired info token)
  (db/delete-auth-by-token db/config
                           {:token token})
  (res/ok {:info (dissoc info :password :exp :expire)
           :message "Logged out"}))

;; tests

(comment)
