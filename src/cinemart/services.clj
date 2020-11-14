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
  (last
   (clojure.string/split
    (get-in req [:headers "authorization"]) #" ")))

(defn token-valid? [req]
  (not (empty? (db/get-auth-by-token db/config
                                     {:token (strip-token req)}))))

(defn token-expired? [req]
  (let [token (strip-token req)
        user-info (decreate-token token)
        exp (:exp user-info)
        id (:id user-info)]
    (if (< (now) exp)
      false
      (db/delete-auth-by-token db/config
                               {:user-id id
                                :token token}))))

(defn admin? [req]
  (:admin (decreate-token (strip-token req))))

(comment
  (admin? {:headers {"authorization" "eyJhbGciOiJIUzI1NiJ9.eyJhZG1pbiI6ZmFsc2UsInBhc3N3b3JkIjoiYmNyeXB0K3NoYTUxMiQyOWEyYmZlYWE2NjMzNzA0ODdlMjNkNTNiYTRmMmQxYSQxMiRjNWQzOTIxNTY3ZWIwNGIyNTVlNjE5Nzk5NzYxYzAyM2FkNzhjNzExNzIyY2JiMzgiLCJtYWlsIjoibXJAZG9lIiwiZXhwIjoxNjA1Mzg4MTg5MTU5LCJ1c2VybmFtZSI6Im1yZG9lIiwiZnVsbG5hbWUiOiJNciBEb2UiLCJkb2IiOiIxLTMtMTk2MCIsImlkIjoxNywiY3JlYXRlZF9hdCI6MTYwNTM3NDcyNn0.qjkkcV7DVSLpJc7-MfQCHJLdboQ3fmoAGl0eTWsoZZU"}})
  (let [user (add-token {:name "alo"})
        token (:token user)
        refresh-token (:refresh-token user)]
    ;(jwt/unsign token secret)
    (jwt/unsign refresh-token secret)))
