(ns cinemart.middleware
  (:require [ring.util.http-response :as res]
            [cinemart.db :as db]
            [cinemart.services :as s]
            [cinemart.auth :as auth]))

(defn hashpass [next]
  (fn [req]
    (let [info (get-in req [:parameters :body])]
      (if (:password info)
        (next (assoc-in req [:parameters :body] (s/hashpass info)))
        (next req)))))

(defn create-person [req next get-by-mail]
  (let [mail (get-in req [:parameters :body :mail])]
    (if (get-by-mail db/config {:mail mail})
      (res/bad-request {:error "Mail is already used"})
      (next req))))

(defn create-user [next]
  (fn [req]
    (create-person req next db/get-user-by-mail)))

;; check if token valid

(defn basic-valid [req next get-auth key]
  (let [t (get-in req [:parameters :header :authorization])
        token (if (string? t) (last (clojure.string/split t #" ")) nil)
        info (s/decreate-token token)]
    (if token
      (if (and info
               (get-auth db/config {key token}))
        (next (assoc req :token token :info info))
        (res/unauthorized {:error "Token invalid"}))
      (res/unauthorized {:error "Token required"}))))

(defn token-valid [next]
  (fn [req]
    (basic-valid req next db/get-auth-by-token :token)))

(defn rtoken-valid [next]
  (fn [req]
    (basic-valid (assoc req :refresh-token true) next
                 db/get-auth-by-refresh-token
                 :refresh-token)))

;; check if token not expired
(defn not-expired [next]
  (fn [req]
    (if (< (s/now) (get-in req [:info :expire]))
      (next req)
      (do (when (:refresh-token req)
            (db/delete-auth-by-refresh-token db/config {:refresh-token (:token req)}))
          (res/unauthorized {:error "Token expired"})))))

(defn roles [next & r]
  (fn [req]
    (if (contains? r (:role req))
      (next req)
      (res/unauthorized
       {:error (str
                (apply str (interpose ", " r))
                " place")}))))

(comment
  (db/delete-auth-by-refresh-token db/config {:refresh-token "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoidXNlciIsInBhc3N3b3JkIjoiYmNyeXB0K3NoYTUxMiQ1MDM0YzFjNGNlM2E2YjhlNDNhNmQ5OTQ5ZGE3MGViZCQxMiQzYjc5MTA5NTczNTUyMWUyMTRlZmY0NGEzODY2ZTU0Yzc5NGRjMGY4YWE4OTFkOTIiLCJtYWlsIjoic3RyaW5nIiwiZXhwIjoxNjA2Njk5MzQ3NTg3LCJ1c2VybmFtZSI6InN0cmluZyIsImZ1bGxuYW1lIjoic3RyaW5nIiwiZXhwaXJlIjoxNjA2Njk5MzQ3NTg2LCJkb2IiOiJzdHJpbmciLCJpZCI6MjUsImNyZWF0ZWRfYXQiOjE2MDY2NTM0NTR9.yIB4gXm0d0JFDtt0DyLf5z2dKoo8FCjWa1PsyhVLNo8"}))

;; check if login

(defn basic-auth [req next valid? not-expired?]
  (if (valid? req)
    (if-let [role (not-expired? req)]
      (next (assoc req :role role))
      (res/unauthorized {:error "Token expired"}))
    (res/unauthorized {:error "Token invalid"})))

(defn auth [next]
  (fn [req]
    (basic-auth req next s/token-valid? s/token-not-expired?)))

(defn reauth [next]
  (fn [req]
    (basic-auth req next s/ref-token-valid? s/ref-token-not-expired?)))

(defn admin [next]
  (fn [req]
    (if (= (:role req) "admin")
      (next req)
      (res/unauthorized {:error "Admin place"}))))

(defn manager-or-admin [next]
  (fn [req]
    (if (or (= (:role req) "admin") (= (:role req) "manager"))
      (next req)
      (res/unauthorized {:error "Manager & Admin place"}))))

(defn manager [next]
  (fn [req]
    (if (= (:role req) "manager")
      (next req)
      (res/unauthorized {:error "Manager place"}))))

(comment
  ((reauthenticate auth/refresh) {:headers {"authorization" "eyJhbGciOiJIUzI1NiJ9.eyJhZG1pbiI6ZmFsc2UsInBhc3N3b3JkIjoiYmNyeXB0K3NoYTUxMiQyOWEyYmZlYWE2NjMzNzA0ODdlMjNkNTNiYTRmMmQxYSQxMiRjNWQzOTIxNTY3ZWIwNGIyNTVlNjE5Nzk5NzYxYzAyM2FkNzhjNzExNzIyY2JiMzgiLCJtYWlsIjoibXJAZG9lIiwiZXhwIjoxNjA1NDI0NjE3ODk3LCJ1c2VybmFtZSI6Im1yZG9lIiwiZnVsbG5hbWUiOiJNciBEb2UiLCJkb2IiOiIxLTMtMTk2MCIsImlkIjoxNywiY3JlYXRlZF9hdCI6MTYwNTM3NDcyNn0.2gcdR-b9kGFrs-R7EVzdaIYEWdPFK7AjUwcdtViHKcE"}}))
