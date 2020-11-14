(ns cinemart.auth
  (:require [ring.util.http-response :as res]
            [cinemart.db :as db]
            [cinemart.services :as s]
            [cinemart.middleware :as mw]))

(defn login [{:keys [parameters]}]
  (let [mail (get-in parameters [:body :mail])
        user (db/get-user-by-mail db/config {:mail mail})
        password (get-in parameters [:body :password])]
    (println user)
    (if user
      (if (s/checkpass password user)
        (res/ok {:user (s/add-token user)})
        (res/unauthorized {:error "Wrong password"}))
      (res/not-found {:error "User not found"}))))

(comment
  (register {:parameters {:body {:mail "miss@john.com"
                                 :dob "29/2/2004"
                                 :password "password"
                                 :fullname "Miss John"
                                 :username "missjohn"}}})
  (login {:parameters {:body {:mail "miss@john.com"
                              :password "password"}}}))

(comment
  (defn login-fn
    [request {:keys [mail password]}]
    (println "work?")
    true)
  (def login
    (http-basic-backend
     {:authfn login-fn})))



