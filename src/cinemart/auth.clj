(ns cinemart.auth
  (:require [ring.util.http-response :as res]
            [cinemart.db :as db]
            [cinemart.services :as s]))

(defn refresh [{:keys [token info]}]
  (db/delete-auth-by-refresh-token db/config
                                   {:refresh-token token})
  (res/ok {:response
           (s/add-token info (:role info))}))

(defn register [{:keys [parameters]}, role]
  (let [data (:body parameters)
        user (-> data
                 ((partial db/insert-user db/config))
                 (s/add-token role))]
    (res/created
     (str "/user/" (:id user))
     {:response user})))

(defn login [{:keys [parameters]} role]
  (let [mail (get-in parameters [:body :mail])
        [get-db] (s/mail-get-func-by-role role)
        account (get-db db/config {:mail mail})
        password (get-in parameters [:body :password])]
    (if account
      (if (try (s/checkpass password account)
               (catch Exception e false))
        (res/ok {:response (s/add-token account role)})
        (res/unauthorized {:error "wrong password"}))
      (res/not-found {:error (str role " not found")}))))

;; log out from other device and clean dead tokens
(defn logout-from-other-devices [{:keys [token info]}]
  (s/revoke-all-tokens
   (:id info) (:role info)
   [(fn [t] (not= token (:token t)))])
  (res/ok {:message "logged out from all other devices"}))

;; log out and clean dead tokens
(defn logout [{:keys [token info]}]
  (s/revoke-all-tokens
   (:id info) (:role info)
   [(fn [t] (= token (:token t)))])
  (res/ok {:response (dissoc info :password :expire)
           :message "logged out"}))

;; tests

(comment)
