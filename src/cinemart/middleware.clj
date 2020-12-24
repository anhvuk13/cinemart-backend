(ns cinemart.middleware
  (:require [clojure.string :refer [split join]]
            [ring.util.http-response :as res]
            [clj-time.core :as c]
            [clj-time.format :as f]
            [custom.config :refer [server-path]]
            [utils.coerce :as coerce]
            [cinemart.db :as db]
            [cinemart.services :as s]
            [cinemart.auth :as auth]))

(defn hashpass [next]
  (fn [req]
    (let [info (get-in req [:parameters :body])]
      (if (:password info)
        (next (assoc-in req [:parameters :body] (s/hashpass info)))
        (next req)))))

(defn movie-img [next]
  (fn [req]
    (let [raw-movie (get-in req [:parameters :body])
          path (if (= (str (last server-path) "/")) (join (drop-last server-path)) server-path)
          poster (str path "/assets/poster.jpg");
          backdrop (str path "/assets/backdrop.png")
          poster_path (if (empty? (:poster_path raw-movie)) poster (:poster_path raw-movie))
          backdrop_path (if (empty? (:backdrop_path raw-movie)) backdrop (:backdrop_path raw-movie))]
      (next (update-in req [:parameters :body] assoc :poster_path poster_path :backdrop_path backdrop_path)))))

(defn create-person [req next get-by-mail]
  (let [mail (get-in req [:parameters :body :mail])]
    (if (get-by-mail db/config {:mail mail})
      (res/bad-request {:error "mail is already used"})
      (next req))))

(defn create-user [next]
  (fn [req]
    (create-person req next db/get-user-by-mail)))

(defn create-manager [next]
  (fn [req]
    (let [id (get-in req [:parameters :body :theater])]
      (if (empty? (db/get-theater-by-id db/config {:id id}))
        (res/bad-request {:error "theater not exists"})
        (create-person req next db/get-manager-by-mail)))))

(defn create-admin [next]
  (fn [req]
    (create-person req next db/get-admin-by-mail)))

;; check if token valid
(defn basic-valid [req next get-auth key]
  (let [t (get-in req [:parameters :header :authorization])
        token (if (string? t) (last (split t #" ")) nil)
        info (s/decreate-token token)
        user-agent (get-in req [:headers "user-agent"])]
    (if token
      (if (empty? (get-auth db/config {key token}))
        (res/unauthorized {:error "token invalid"})
        (if (= user-agent (:user-agent info))
          (next (assoc req :token token :info (dissoc info :user-agent)))
          (res/unauthorized {:error "have you just stolen this token?"})))
      (res/unauthorized {:error "token required"}))))

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
    (if (and (:info req)
             (< (s/now) (get-in req [:info :expire])))
      (next (update-in req [:info] dissoc :expire))
      (do (when (:refresh-token req)
            (db/delete-auth-by-refresh-token db/config {:refresh-token (:token req)}))
          (res/unauthorized {:error "token expired"})))))

(defn roles [next & r]
  (fn [req]
    (if (some #(= % (get-in req [:info :role])) r)
      (next req)
      (res/unauthorized
       {:error (str
                (apply str (interpose ", " r))
                " place")}))))

(defn managing? [next]
  (fn [req]
    (if (and (= (get-in req [:info :role]) "manager")
             (empty?
              (db/check-management-exists
               db/config
               {:theater (get-in req [:parameters :path :id])
                :manager (get-in req [:info :id])})))
      (res/unauthorized {:error "you're not in charge of managing this theater"})
      (next req))))

(defn user-own-invoice? [next]
  (fn [req]
    (let [info (:info req)
          id (get-in req [:parameters :path])
          invoice (db/get-invoice-by-id db/config id)]
      (if (and (= "user" (:role info))
               (not= (:id info) (:user_id invoice)))
        (res/unauthorized {:error "you not own this invoice"})
        (next (assoc req :before-deleted invoice))))))

(defn StrInt? [next & args]
  (fn [req]
    ((fn [req [key & rest]]
       (let [val-str (get-in req [:parameters :body key])
             val (s/parse-int val-str)
             next-req (assoc-in req [:parameters :body key] val)]
         (if (nil? val)
           (res/bad-request
             {:error (str key " must be StrInt (ex: '1', '2',...)")})
           (if (empty? rest)
             (next next-req)
             (recur next-req rest))))) req args)))

(defn StrTime? [next & args]
  (fn [req]
    ((fn [req [key & rest]]
       (let [val-str (get-in req [:parameters :body key])
             val (f/parse val-str)
             next-req (assoc-in req [:parameters :body key] val)]
         (if (nil? val)
           (res/bad-request
             {:error (str key " must be iso time string (ex: '" (str (c/now)) "')")})
           (if (empty? rest)
             (next next-req)
             (recur next-req rest))))) req args)))

(defn ToPgJson [next & args]
  (fn [req]
    ((fn [req [key & rest]]
       (let [val-json (get-in req [:parameters :body key])
             val (coerce/to-pg-json val-json)
             next-req (assoc-in req [:parameters :body key] val)]
         (if (empty? rest)
           (next next-req)
           (recur next-req rest)))) req args)))

(defn draw-old-data [next get-db]
  (fn [req]
    (let [id (get-in req [:parameters :path])
          old-data (get-db db/config id)
          data (get-in req [:parameters :body])]
      (next
        (assoc (assoc-in req
                         [:parameters :body]
                         (merge old-data data))
               :old-data old-data)))))

(comment
  ((roles #(println %) "admin" "user" "manager") {:role "manager"})
  (db/delete-auth-by-refresh-token db/config {:refresh-token "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoidXNlciIsInBhc3N3b3JkIjoiYmNyeXB0K3NoYTUxMiQ1MDM0YzFjNGNlM2E2YjhlNDNhNmQ5OTQ5ZGE3MGViZCQxMiQzYjc5MTA5NTczNTUyMWUyMTRlZmY0NGEzODY2ZTU0Yzc5NGRjMGY4YWE4OTFkOTIiLCJtYWlsIjoic3RyaW5nIiwiZXhwIjoxNjA2Njk5MzQ3NTg3LCJ1c2VybmFtZSI6InN0cmluZyIsImZ1bGxuYW1lIjoic3RyaW5nIiwiZXhwaXJlIjoxNjA2Njk5MzQ3NTg2LCJkb2IiOiJzdHJpbmciLCJpZCI6MjUsImNyZWF0ZWRfYXQiOjE2MDY2NTM0NTR9.yIB4gXm0d0JFDtt0DyLf5z2dKoo8FCjWa1PsyhVLNo8"}))

;; check if login

(defn basic-auth [req next valid? not-expired?]
  (if (valid? req)
    (if-let [role (not-expired? req)]
      (next (assoc req :role role))
      (res/unauthorized {:error "token expired"}))
    (res/unauthorized {:error "token invalid"})))

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
      (res/unauthorized {:error "admin place"}))))

(defn manager-or-admin [next]
  (fn [req]
    (if (or (= (:role req) "admin") (= (:role req) "manager"))
      (next req)
      (res/unauthorized {:error "manager & admin place"}))))

(defn manager [next]
  (fn [req]
    (if (= (:role req) "manager")
      (next req)
      (res/unauthorized {:error "manager place"}))))

(comment
  ((reauthenticate auth/refresh) {:headers {"authorization" "eyJhbGciOiJIUzI1NiJ9.eyJhZG1pbiI6ZmFsc2UsInBhc3N3b3JkIjoiYmNyeXB0K3NoYTUxMiQyOWEyYmZlYWE2NjMzNzA0ODdlMjNkNTNiYTRmMmQxYSQxMiRjNWQzOTIxNTY3ZWIwNGIyNTVlNjE5Nzk5NzYxYzAyM2FkNzhjNzExNzIyY2JiMzgiLCJtYWlsIjoibXJAZG9lIiwiZXhwIjoxNjA1NDI0NjE3ODk3LCJ1c2VybmFtZSI6Im1yZG9lIiwiZnVsbG5hbWUiOiJNciBEb2UiLCJkb2IiOiIxLTMtMTk2MCIsImlkIjoxNywiY3JlYXRlZF9hdCI6MTYwNTM3NDcyNn0.2gcdR-b9kGFrs-R7EVzdaIYEWdPFK7AjUwcdtViHKcE"}}))
