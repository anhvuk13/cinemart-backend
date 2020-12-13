(ns cinemart.invoices
  (:require [ring.util.http-response :as res]
            [clj.invoices :as i]
            [cinemart.db :as db]))

(defn get-invoices [req]
  (res/ok {:response (db/get-invoices db/config)}))

(defn get-invoice-by-id [{:keys [parameters]}]
  (res/ok {:response (i/get-invoice-by-id (get-in parameters [:path :id]))}))

(defn create-invoices [{:keys [parameters]}]
  (let [user (get-in parameters [:body :user])
        schedule (get-in parameters [:body :schedule])
        booked_seats (get-in parameters [:body :booked_seats])
        seats_name (get-in parameters [:body :seats_name])
        invoice (:id
                  (db/insert-invoice db/config {:user_id user
                                                :schedule schedule}))
        price (:price
                (db/get-schedule-by-id db/config {:id schedule}))]
    (println (apply map (fn [seat name]
                          (db/insert-ticket db/config {:invoice invoice
                                                       :seat seat
                                                       :seat_name name
                                                       :price price}))
                    [booked_seats seats_name]))

    (res/ok {:response
             (db/get-invoice-by-id db/config {:id invoice})})))
