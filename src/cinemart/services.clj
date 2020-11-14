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

(defn add-token [user]
  (let [user (assoc user
                    :token (create-token user (token-exp))
                    :refresh-token (create-token user (ref-token-exp)))]
    (dissoc user :password)))

(defn hashpass [user]
  (assoc user :password (h/derive (:password user))))

(defn checkpass [password user]
  (h/check password (:password user)))

(comment
  (let [user (add-token {:name "alo"})
        token (:token user)
        refresh-token (:refresh-token user)]
    ;(jwt/unsign token secret)
    (jwt/unsign refresh-token secret)))
