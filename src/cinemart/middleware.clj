(ns cinemart.middleware
  (:require [ring.util.http-response :as res]
            [cinemart.db :as db]
            [cinemart.services :as s]))

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
