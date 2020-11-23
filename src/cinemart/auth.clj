(ns cinemart.auth
  (:require [ring.util.http-response :as res]
            [cinemart.db :as db]
            [cinemart.services :as s]))

(defn refresh [req]
  (let [ref-token (s/strip-token req)
        user (s/decreate-token ref-token)]
    (db/delete-auth-by-refresh-token db/config
                                     {:user-id (:id user)
                                      :refresh-token ref-token})
    (res/ok {:user
             (s/add-token
              (dissoc user
                      [:token :refresh-token]))})))

(defn register [{:keys [parameters]}]
  (let [data (:body parameters)
        user (-> data
                 (s/hashpass)
                 ((partial db/insert-user db/config))
                 ((partial db/get-user-by-id db/config))
                 (s/add-token "user"))]
    (res/created
     (str "/user/" (:id user))
     {:user user})))

(comment (register {:parameters {:body
                                 {:fullname "John Doe"
                                  :username "johndoe"
                                  :mail "john@doe"
                                  :dob "1/1/1990"
                                  :password "password"}}}))

(defn login [{:keys [parameters]} role]
  (println role)
  (let [mail (get-in parameters [:body :mail])
        user (db/get-user-by-mail db/config {:mail mail})
        password (get-in parameters [:body :password])]
    (if user
      (if (s/checkpass password user)
        (res/ok {:user (s/add-token user role)})
        (res/unauthorized {:error "Wrong password"}))
      (res/not-found {:error "User not found"}))))

(comment
(login {:parameters {:body
                     {:mail "john@doe"
                      :password "password"}}}
       "user"))

(defn user-login [req]
  (login req "user"))

(defn manager-login [req]
  (login req "manager"))

(defn admin-login [req]
  (login req "admin"))

(defn logout [req]
  (let [token (s/strip-token req)]
    (db/delete-auth-by-token db/config
                             {:token token})
    (res/ok {:info (s/decreate-token token)
             :message "Logged out"})))

(defn logout-from-other-devices [req]
  (res/ok {:message "coming soon"}))

(comment
  (refresh {:headers {"authorization" "Token eyJhbGciOiJIUzI1NiJ9.eyJhZG1pbiI6ZmFsc2UsInBhc3N3b3JkIjoiYmNyeXB0K3NoYTUxMiQyOWEyYmZlYWE2NjMzNzA0ODdlMjNkNTNiYTRmMmQxYSQxMiRjNWQzOTIxNTY3ZWIwNGIyNTVlNjE5Nzk5NzYxYzAyM2FkNzhjNzExNzIyY2JiMzgiLCJtYWlsIjoibXJAZG9lIiwiZXhwIjoxNjA1NDE0MTY4NzY3LCJ1c2VybmFtZSI6Im1yZG9lIiwiZnVsbG5hbWUiOiJNciBEb2UiLCJkb2IiOiIxLTMtMTk2MCIsImlkIjoxNywiY3JlYXRlZF9hdCI6MTYwNTM3NDcyNn0.9djdr_yDsVhh4E_p5lcEXI-ilOwtbhH_zGrwv3P4eoQ"}})
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



