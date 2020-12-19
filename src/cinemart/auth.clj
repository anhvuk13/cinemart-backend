(ns cinemart.auth
  (:require [ring.util.http-response :as res]
            [cinemart.db :as db]
            [cinemart.services :as s]))

(defn refresh [req]
  (let [token (:token req)
        info (:info req)]
    (db/delete-auth-by-refresh-token db/config
                                     {:refresh-token token})
    (res/ok {:response
             (s/add-token req info (:role info))})))

(defn register [req role]
  (let [data (get-in req [:parameters :body])
        user (-> data
                 ((partial db/insert-user db/config))
                 ((partial db/get-user-by-id db/config))
                 ((partial s/add-token req) role))]
    (res/created
     (str "/users/" (:id user))
     {:response user})))

(defn login [req role]
  (let [mail (get-in req [:parameters :body :mail])
        [get-db] (s/mail-get-func-by-role role)
        account (get-db db/config {:mail mail})
        password (get-in req [:parameters :body :password])]
    (if account
      (if (try (s/checkpass password account)
               (catch Exception e false))
        (res/ok {:response (s/add-token req account role)})
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
  (res/ok {:response info
           :message "logged out"}))

;; tests

(comment)
