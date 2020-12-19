(ns cinemart.services
  (:require [custom.config :as c]
            [cinemart.db :as db]
            [buddy.hashers :as h]
            [buddy.sign.jwt :as jwt])
  (:import java.util.Date))

(defn parse-int [number-string]
  (if (int? number-string)
    number-string
    (try (Integer/parseInt number-string)
         (catch Exception e nil))))

(def secret c/secret)
(def token-valid c/token-valid)
(def ref-token-valid c/ref-token-valid)

(defn now []
  (* (.getTime (java.util.Date.))))

(defn token-exp []
  (+ (now) (* 1000 token-valid)))

(defn ref-token-exp []
  (+ (now) (* 1000 ref-token-valid)))

(defn create-token [user exp]
  (jwt/sign (assoc user :expire exp) secret))

(defn decreate-token [token]
  (try
    (jwt/unsign token secret)
    (catch Exception e nil)))

(defn add-token [req data role]
  (let [user-agent (get-in req [:headers "user-agent"])
        user-info (assoc data :user-agent user-agent :role role)
        info (dissoc user-info :password)
        user (assoc info
                    :token (create-token info (token-exp))
                    :refresh-token (create-token info (ref-token-exp)))]
    (db/insert-auth db/config
                    {:token (:token user)
                     :refresh-token (:refresh-token user)})
    (dissoc user :user-agent :expire)))

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

(defn token-alive? [token]
  (let [t (decreate-token token)]
    (and (boolean t)
         (< (now) (:expire t)))))

(defn token-dead? [token]
  (not (token-alive? token)))

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

(defn revoke-all-tokens [id role checklist]
  (doseq [t (db/get-auth db/config)]
    (let [token (:token t)
          rtoken (:refresh_token t)
          info (decreate-token rtoken)
          info-id (:id info)
          info-role (:role info)]
      (if (or (not info)
              (>= (now) (:expire info))
              (and (= id info-id)
                   (= role info-role)
                   (reduce
                    (fn [res item]
                      (and res (item t)))
                    true checklist)))
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
    "admin" [db/get-admins-without-pass]
    "manager" [db/get-managers-without-pass]
    [db/get-users-without-pass]))

(defn get-func-by-role [role]
  (case role
    "admin" [db/get-admin-by-id db/update-admin-by-id db/delete-admin-by-id]
    "manager" [db/get-manager-by-id db/update-manager-by-id db/delete-manager-by-id]
    [db/get-user-by-id db/update-user-by-id db/delete-user-by-id]))

(comment
  (decreate-token "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoidXNlciIsInBhc3N3b3JkIjoiYmNyeXB0K3NoYTUxMiQ5MGJmNTQwMGU0ODdkNjcyMWE3ZTBmZmUxZWQxN2FlNCQxMiQ3NDQxYzFmZGVmNDZlZjFhZGRlZTdmYWZiZWRhMWU1OGVlODI1N2I0OGM4YTRjNDEiLCJtYWlsIjoic3RyaW5nIiwidXNlcm5hbWUiOiJzdHJpbmciLCJmdWxsbmFtZSI6InN0cmluZyIsImV4cGlyZSI6MTYwNzE1NTk4OTUwOCwiZG9iIjoiMS8yLzExOTMiLCJpZCI6MzIsImNyZWF0ZWRfYXQiOjE2MDY4OTQ3OTl9.BbtIR2K9ETYKnPUk4SuT2DcZS0Gf1teriykTwBa5NMQ"))
