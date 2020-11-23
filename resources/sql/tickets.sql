-- :name create-tickets-table
-- :command :execute
-- :result :raw
-- :doc creates tickets table
CREATE TABLE IF NOT EXISTS tickets (
  invoice SERIAL NOT NULL,
  seat INTEGER NOT NULL,
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
  update invoices set cost = cost + new.price where invoices.id = new.invoice;
  RETURN NEW;
END;
$$;
CREATE OR REPLACE FUNCTION delete_tickets_trigger()
  RETURNS TRIGGER
  LANGUAGE PLPGSQL
  AS
$$
BEGIN
  update invoices set cost = cost - old.price where invoices.id = old.invoice;
  RETURN NEW;
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

-- :name get-seats-of-invoice :? :1
SELECT seat FROM tickets
WHERE invoice = :invoices;

-- :name get-ticket-by-invoice-and-seat
SELECT * FROM tickets
WHERE invoice = :invoices AND seat = :seat;

-- :name insert-ticket :? :1
INSERT INTO tickets (invoice, seat, price)
VALUES (:invoice, :seat, :price)
RETURNING invoice, seat;

-- :name delete-ticket-by-invoice-and-seat :! :1
DELETE FROM tickets
WHERE invoice = :invoice
AND seat = :seat;
