(ns cinemart.services
  (:require [cinemart.db :as db]
            [buddy.hashers :as h]
            [buddy.sign.jwt :as jwt]))
(import java.util.Date)

(defonce secret "secret")
(defonce token-valid 1)
(defonce ref-token-valid 5)

(defn now []
  (* (.getTime (java.util.Date.))))

(defn token-exp []
  (+ (now) (* 60000 token-valid)))

(defn ref-token-exp []
  (+ (now) (* 60000 ref-token-valid)))

(defn create-token [user exp]
  (jwt/sign user secret {:exp exp}))

(defn decreate-token [token]
  (try
    (jwt/unsign token secret)
    (catch Exception e nil)))

(defn add-token [user]
  (let [user (assoc user
                    :token (create-token user (token-exp))
                    :refresh-token (create-token user (ref-token-exp)))]
    (db/insert-auth db/config
                    {:user-id (:id user)
                     :token (:token user)
                     :refresh-token (:refresh-token user)})
    (dissoc user :password)))

(defn hashpass [user]
  (assoc user :password (h/derive (:password user))))

(defn checkpass [password user]
  (h/check password (:password user)))

(defn strip-token [req]
  (if-let [token (get-in req [:headers "authorization"])]
    (last (clojure.string/split token #" "))
    nil))

(defn token-valid? [req]
  (if-let [token (strip-token req)]
    (not (empty? (db/get-auth-by-token db/config
                                       {:token token})))
    false))

(defn ref-token-valid? [req]
  (if-let [ref-token (strip-token req)]
    (not (empty? (db/get-auth-by-refresh-token db/config
                                               {:refresh-token ref-token})))
    false))

(defn token-expired? [req]
  (let [token (strip-token req)
        user-info (decreate-token token)
        exp (:exp user-info)
        id (:id user-info)]
    (if (< (now) exp) false [id token])))

(defn ref-token-expired? [req]
  (if-let [[id token] (token-expired? req)]
    (db/delete-auth-by-refresh-token db/config
                                     {:user-id id
                                      :refresh-token token})
    false))

(defn admin? [req]
  (:admin (decreate-token (strip-token req))))

(defn revoke-all-expired-tokens [{:keys [id]}]
  (doseq [{:keys [refresh_token]}
          (db/get-auth-by-user-id db/config
                                  {:user-id id})]
    (let [exp (:exp (jwt/unsign refresh_token secret))]
      (if (>= (now) exp)
        (db/delete-auth-by-refresh-token
         db/config
         {:user-id id
          :refresh-token refresh_token})))))

(comment
  (revoke-all-expired-tokens {:id 17})
  (ref-token-expired? {:headers {"authorization" "eyJhbGciOiJIUzI1NiJ9.eyJhZG1pbiI6ZmFsc2UsInBhc3N3b3JkIjoiYmNyeXB0K3NoYTUxMiQyOWEyYmZlYWE2NjMzNzA0ODdlMjNkNTNiYTRmMmQxYSQxMiRjNWQzOTIxNTY3ZWIwNGIyNTVlNjE5Nzk5NzYxYzAyM2FkNzhjNzExNzIyY2JiMzgiLCJtYWlsIjoibXJAZG9lIiwiZXhwIjoxNjA1NDI0MDkwMzgwLCJ1c2VybmFtZSI6Im1yZG9lIiwiZnVsbG5hbWUiOiJNciBEb2UiLCJkb2IiOiIxLTMtMTk2MCIsImlkIjoxNywiY3JlYXRlZF9hdCI6MTYwNTM3NDcyNn0.eVpnqs_VndTDE8Y126yr1hhJgAVHL-4hq6LWavOA8Eg"}})
  (let [user (add-token {:name "alo"})
        token (:token user)
        refresh-token (:refresh-token user)]
    (jwt/unsign token secret)
    (jwt/unsign refresh-token secret)))
