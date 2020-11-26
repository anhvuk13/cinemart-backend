(ns cinemart.auth
  (:require [ring.util.http-response :as res]
            [cinemart.db :as db]
            [cinemart.services :as s]))

(defn refresh [req]
  (let [ref-token (s/strip-token req)
        user (s/decreate-token ref-token)]
    (db/delete-auth-by-refresh-token db/config
                                     {:refresh-token ref-token})
    (res/ok {:user
             (s/add-token user (:role user))})))

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

;; log out from current token

(defn logout [req]
  (let [token (s/strip-token req)]
    (db/delete-auth-by-token db/config
                             {:token token})
    (res/ok {:info (-> (s/decreate-token token)
                       (dissoc :password :exp :expire))
             :message "Logged out"})))

;; log out from other device

(defn delete-other-tokens-bound-to-user
  (;; delete all other tokens
   [req current-token]
   (delete-other-tokens-bound-to-user req current-token (fn [_] true)))
  (;; delete other tokens with additional condition (check)
   [{:keys [role id]} current-token check]
   (doseq [t (db/get-auth db/config)]
     (let [token (:token t)
           info (s/decreate-token token)
           info-id (:id info)
           info-role (:role info)]
       (if (and (= id info-id)
                (= role info-role)
                (not= token current-token)
                (check token))
         (do
           (println (check token))
           (db/delete-auth-by-token db/config {:token token})))))))

(defn logout-from-other-devices [req]
  (let [token (s/strip-token req)]
    (delete-other-tokens-bound-to-user
     (s/decreate-token token) token))
  (res/ok {:message "Logged out from all other devices"}))

;; tests

(comment)
