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
        [get-db] (s/mail-get-func-by-role role)
        user (get-db db/config {:mail mail})
        password (get-in parameters [:body :password])]
    (if user
      (if (try (s/checkpass password user)
               (catch Exception e false))
        (res/ok {:user (s/add-token user role)})
        (res/unauthorized {:error "Wrong password"}))
      (res/not-found {:error "User not found"}))))

;; log out from other device and clean dead tokens
(defn logout-from-other-devices [{:keys [token info]}]
  (s/revoke-all-tokens
   (:id info) (:role info)
   [(fn [t]
      (not= token (:token t)))])
  (res/ok {:message "Logged out from all other devices"}))

;; log out and clean dead tokens
(defn logout [{:keys [token info]}]
  (s/revoke-all-tokens
   (:id info) (:role info)
   [(fn [t]
      (or (s/token-dead? (:refresh_token t))
          (= token (:token t))))])
  (res/ok {:info (dissoc info :password :exp :expire)
           :message "Logged out"}))

;; tests

(comment)
