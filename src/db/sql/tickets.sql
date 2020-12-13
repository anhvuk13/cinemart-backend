-- :name create-tickets-table
-- :command :execute
-- :result :raw
-- :doc creates tickets table
CREATE TABLE IF NOT EXISTS tickets (
  invoice SERIAL NOT NULL,
  seat INTEGER NOT NULL,
  seat_name TEXT NOT NULL,
  price INTEGER NOT NULL,
  PRIMARY KEY (invoice, seat),
  CONSTRAINT fk_invoice
    FOREIGN KEY (invoice)
      REFERENCES invoices (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp
);
CREATE OR REPLACE FUNCTION insert_tickets_trigger()
  RETURNS TRIGGER
  LANGUAGE PLPGSQL
  AS
$$
BEGIN
  update invoices
  set cost = cost + new.price,
      tickets_count = tickets_count + 1
  where invoices.id = new.invoice;
  RETURN NEW;
END;
$$;
CREATE OR REPLACE FUNCTION delete_tickets_trigger()
  RETURNS TRIGGER
  LANGUAGE PLPGSQL
  AS
$$
BEGIN
  update invoices
  set cost = cost - old.price,
      tickets_count = tickets_count - 1
  where invoices.id = old.invoice;
  RETURN OLD;
END;
$$;
DROP TRIGGER IF EXISTS tg_insert_tickets ON tickets;
DROP TRIGGER IF EXISTS tg_delete_tickets ON tickets;
CREATE TRIGGER tg_insert_tickets
  AFTER INSERT
  ON tickets
  FOR EACH ROW
  EXECUTE PROCEDURE insert_tickets_trigger();
CREATE TRIGGER tg_delete_tickets
  AFTER DELETE
  ON tickets
  FOR EACH ROW
  EXECUTE PROCEDURE delete_tickets_trigger();

-- :name drop-tickets-table :!
-- :doc drop tickets table
DROP TABLE IF EXISTS tickets;

-- :name get-tickets :? :*
SELECT * FROM tickets;

-- :name get-seats-of-invoice :? :*
SELECT seat, seat_name FROM tickets
WHERE invoice = :invoices;

-- :name get-ticket-by-invoice-and-seat :? :1
SELECT * FROM tickets
WHERE invoice = :invoices AND seat = :seat;

-- :name get-reserved-seats-of-schedule :? :1
SELECT array_agg(seat) reserved_seats, array_agg(seat_name) reserved_seats_name
FROM tickets
INNER JOIN invoices ON invoices.id = tickets.invoice
INNER JOIN schedules ON schedules.id = invoices.schedule
WHERE schedules.id = :schedule;

-- :name insert-ticket :? :1
INSERT INTO tickets (invoice, seat, seat_name, price)
VALUES (:invoice, :seat, :seat_name, :price)
RETURNING *;

-- :name delete-ticket-by-invoice-and-seat :! :1
DELETE FROM tickets
WHERE invoice = :invoice
AND seat = :seat;
