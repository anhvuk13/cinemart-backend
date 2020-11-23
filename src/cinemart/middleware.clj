(ns cinemart.middleware
  (:require [ring.util.http-response :as res]
            [cinemart.db :as db]
            [cinemart.services :as s]
            [cinemart.auth :as auth]))

(defn create-person [req next get-by-mail]
  (let [mail (get-in req [:parameters :body :mail])]
    (if (get-by-mail db/config {:mail mail})
      (res/bad-request {:error "Mail is already used"})
      (next req))))

(defn create-user [next]
  (fn [req]
    (create-person req next db/get-user-by-mail)))

(defn create-manager [next]
  (fn [req]
    (create-person req next db/get-manager-by-mail)))

(defn create-admin [next]
  (fn [req]
    (create-person req next db/get-admin-by-mail)))

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
