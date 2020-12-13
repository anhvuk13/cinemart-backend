(ns clj.invoices
  (:require [clj-postgresql.core :as pg]
            [clojure.java.jdbc :as jdbc]
            [custom.config :as c]))

(defn get-invoice-by-id [id]
  (let [res (jdbc/query
              c/jdbc-config
              ["SELECT i.id, i.user_id, i.schedule, i.paid, i.cost, array_agg(t.seat) seats, array_agg(t.seat_name) seats_name
               FROM invoices i
               INNER JOIN tickets t
               ON t.invoice = i.id
               WHERE i.id = ?
               GROUP BY i.id, i.user_id, i.schedule, i.paid, i.cost;"
               id])])
  res)
