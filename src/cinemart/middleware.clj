(ns cinemart.middleware
  (:require [ring.util.http-response :as res]
            [cinemart.db :as db]
            [cinemart.services :as s]
            [cinemart.auth :as auth]))

(defn create-user [next]
  (fn [req]
    (let [mail (get-in req [:parameters :body :mail])]
      (if (db/get-user-by-mail db/config {:mail mail})
        (res/bad-request {:error "Mail is already used"})
        (next req)))))

(defn add-admin-field [next]
  (fn [req]
    (next
     (assoc-in req [:parameters :body :admin] false))))

(defn bool-field-convert [next field]
  (fn [req]
    (next
     (assoc-in req [:parameters :body field]
               (= "true" (clojure.string/lower-case
                          (get-in req [:parameters :body field])))))))

(defn reauthenticate [next]
  (fn [req]
    (if (s/ref-token-valid? req)
      (if (s/ref-token-expired? req)
        (res/unauthorized {:error "Refresh token expired"})
        (next req))
      (res/unauthorized {:error "Refresh token invalid"}))))

(defn authenticate [next]
  (fn [req]
    (if (s/token-valid? req)
      (if (s/token-expired? req)
        (res/unauthorized {:error "Token expired"})
        (next req))
      (res/unauthorized {:error "Token invalid"}))))

(defn admin [next]
  (fn [req]
    (if (s/admin? req)
      (next req)
      (res/unauthorized {:error "Admin place"}))))

(comment
  ((reauthenticate auth/refresh) {:headers {"authorization" "eyJhbGciOiJIUzI1NiJ9.eyJhZG1pbiI6ZmFsc2UsInBhc3N3b3JkIjoiYmNyeXB0K3NoYTUxMiQyOWEyYmZlYWE2NjMzNzA0ODdlMjNkNTNiYTRmMmQxYSQxMiRjNWQzOTIxNTY3ZWIwNGIyNTVlNjE5Nzk5NzYxYzAyM2FkNzhjNzExNzIyY2JiMzgiLCJtYWlsIjoibXJAZG9lIiwiZXhwIjoxNjA1NDI0NjE3ODk3LCJ1c2VybmFtZSI6Im1yZG9lIiwiZnVsbG5hbWUiOiJNciBEb2UiLCJkb2IiOiIxLTMtMTk2MCIsImlkIjoxNywiY3JlYXRlZF9hdCI6MTYwNTM3NDcyNn0.2gcdR-b9kGFrs-R7EVzdaIYEWdPFK7AjUwcdtViHKcE"}}))
