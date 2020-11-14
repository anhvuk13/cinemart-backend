(ns cinemart.middleware
  (:require [ring.util.http-response :as res]
            [cinemart.db :as db]))

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
