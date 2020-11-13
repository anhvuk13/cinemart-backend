(ns cinemart.auth
  (:require [cinemart.db :as db]
            [buddy.hashers :as hasher]
            [buddy.sign.jwt :as jwt]
            [buddy.auth.backends.httpbasic :refer [http-basic-backend]]))

(defn res-user
  [user]
  (-> user
      (assoc :token (jwt/sign user "secret"))
      (dissoc :password)))

(defn register
  [{:keys [parameters]}]
  (let [user (:body parameters)
        mail (:mail user)
        password (:password user)]
    (if (db/get-user-by-mail db/config {:mail mail})
      {:status 401
       :body {:error "Mail already exists"}}
      (let [user (assoc user :password (hasher/derive password))]
        (db/insert-user db/config user)
        {:status 200
         :body (res-user user)}))))

(defn login
  [{:keys [parameters]}]
  (let [mail (get-in parameters [:body :mail])
        user (db/get-user-by-mail db/config {:mail mail})
        password (get-in parameters [:body :password])]
    (if user
      (if (hasher/check password (:password user))
        {:status 200
         :body (res-user user)}
        {:status 401
         :body {:error "Wrong password"}})
      {:status 404
       :body {:error "User not found"}})))

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



