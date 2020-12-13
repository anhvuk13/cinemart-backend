(ns cinemart.invoices
  (:require [ring.util.http-response :as res]
            [cinemart.db :as db]))

(defn get-invoices [req]
  (res/ok {:response (db/get-invoices db/config)}))

(defn get-my-invoices [{:keys [info]}]
  (res/ok {:response (db/get-invoices-by-user
                       db/config
                       {:user_id (:id info)})}))

(defn get-invoice-by-id [{:keys [parameters]}]
  (let [invoice (db/get-invoice-by-id db/config (:path parameters))]
    (if invoice
      (res/ok {:response invoice})
      (res/not-found {:error "invoice not found"}))))

(defn delete-invoces [{:keys [parameters before-deleted]}]
  (let [id (:path parameters)
        delete-count (db/delete-invoice-by-id db/config id)]
    (if (= delete-count 1)
      (res/ok {:deleted true
               :response {:before-deleted before-deleted}})
      (res/bad-request {:error "invoice invalid or paid"}))))

(defn create-invoices [{:keys [parameters]}]
  (let [user
        (db/get-user-by-id
          db/config
          {:id (get-in parameters [:body :user])})
        schedule
        (db/get-schedule-by-id
          db/config
          {:id (get-in parameters [:body :schedule])})
        booked_seats (get-in parameters [:body :booked_seats])
        seats_name (get-in parameters [:body :seats_name])]
    (if (or (empty? user)
            (empty? schedule)
            (empty? booked_seats))
      (res/not-found {:error "user, schedule or seats invalid"})
      (let [invoice
            (:id (db/insert-invoice
                   db/config
                   {:user_id (:id user)
                    :schedule (:id schedule)}))
            reserved_seats
            (:reserved_seats (db/get-reserved-seats-of-schedule
                               db/config
                               {:schedule (:id schedule)}))]
        (let [tickets (apply map (fn [seat name]
                                   (if (not (some #{seat} reserved_seats))
                                     (db/insert-ticket db/config {:invoice invoice
                                                                  :seat seat
                                                                  :seat_name name
                                                                  :price (:price schedule)})
                                     false))
                             [booked_seats seats_name])
              inserted? (some true? (map boolean tickets))]
          (println tickets)
          (if inserted?
            (res/ok {:response
                     (db/get-invoice-by-id db/config {:id invoice})})
            (do
              (db/delete-invoice-by-id db/config {:id invoice})
              (res/bad-request {:error "all your choosing seats are reserved"}))))))))

(comment
  (create-invoices {:parameters {:body
                                 {:user 1
                                  :schedule 1
                                  :booked_seats [1 2 3]
                                  :seats_name ["e" "f" "g"]}}}))
