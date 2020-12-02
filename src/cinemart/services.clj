(ns cinemart.services
  (:require [cinemart.db :as db]
            [buddy.hashers :as h]
            [buddy.sign.jwt :as jwt]))
(import java.util.Date)

(defonce secret "secret")
(defonce token-valid 120)
(defonce ref-token-valid 300)

(defn now []
  (* (.getTime (java.util.Date.))))

(defn token-exp []
  (+ (now) (* 1000 token-valid)))

(defn ref-token-exp []
  (+ (now) (* 1000 ref-token-valid)))

(defn create-token [user exp]
  (jwt/sign (assoc user :expire exp) secret {:exp (inc exp)}))

(defn decreate-token [token]
  (try
    (jwt/unsign token secret)
    (catch Exception e nil)))

(defn add-token [data role]
  (let [info (assoc data :role role)
        user (assoc info :token
                    (create-token info (token-exp))
                    :refresh-token (create-token info (ref-token-exp)))]
    (db/insert-auth db/config
                    {:token (:token user)
                     :refresh-token (:refresh-token user)})
    (dissoc user :exp :expire :password)))

(defn hashpass [user]
  (assoc user :password (h/derive (:password user))))

(defn checkpass [password user]
  (h/check password (:password user)))

(defn strip-token [req]
  (if-let [token (get-in req [:headers "authorization"])]
    (last (clojure.string/split token #" "))
    nil))

(defn valid? [req get-auth key]
  (if-let [token (strip-token req)]
    (not (empty? (get-auth db/config
                           {key token})))
    false))

(defn token-valid? [req]
  (valid? req db/get-auth-by-token :token))

(defn ref-token-valid? [req]
  (valid? req db/get-auth-by-refresh-token :refresh-token))

(defn alive? [token]
  (< (now) (:expire (decreate-token token))))

(defn dead? [token]
  (not (alive? token)))

(defn not-expired? [req if-statement]
  (let [token (strip-token req)
        exp (:expire (decreate-token token))]
    (if (< (now) exp) (if-statement token) false)))

(defn token-not-expired? [req]
  (not-expired? req #(:role (decreate-token %))))

(defn ref-token-not-expired? [req]
  (not-expired?
   req
   #(db/delete-auth-by-refresh-token
     db/config
     {:refresh-token %})))

(defn revoke-all-tokens [id role]
  (doseq [t (db/get-auth db/config)]
    (let [token (:token t)
          info (decreate-token token)
          info-id (:id info)
          info-role (:role info)]
      (if (or (not info)
              (and (= id info-id)
                   (= role info-role)))
        (db/delete-auth-by-token db/config {:token token})))))

(defn insert-func-by-role [role]
  (case role
    "admin" [db/insert-admin]
    "manager" [db/insert-manager]
    [db/insert-user]))

(defn mail-get-func-by-role [role]
  (case role
    "admin" [db/get-admin-by-mail]
    "manager" [db/get-manager-by-mail]
    [db/get-user-by-mail]))

(defn get-many-func-by-role [role]
  (case role
    "admin" [db/get-admins]
    "manager" [db/get-managers]
    [db/get-users]))

(defn get-func-by-role [role]
  (case role
    "admin" [db/get-admin-by-id db/update-admin-by-id db/delete-admin-by-id]
    "manager" [db/get-manager-by-id db/update-manager-by-id db/delete-manager-by-id]
    [db/get-user-by-id db/update-user-by-id db/delete-user-by-id]))

(comment)
