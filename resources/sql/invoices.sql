-- :name create-invoices-table
-- :command :execute
-- :result :raw
-- :doc creates invoices table
CREATE TABLE IF NOT EXISTS invoices (
  id SERIAL PRIMARY KEY,
  user_id SERIAL NOT NULL,
  schedule SERIAL NOT NULL,
  paid BOOL NOT NULL DEFAULT FALSE,
  cost INTEGER NOT NULL DEFAULT 0,
  CONSTRAINT fk_user
    FOREIGN KEY (user_id)
      REFERENCES users (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
  CONSTRAINT fk_schedule
    FOREIGN KEY (schedule)
      REFERENCES schedules (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp
);

-- :name drop-invoices-table :!
-- :doc drop invoices table
DROP TABLE IF EXISTS invoices;

-- :name get-invoices :? :*
SELECT * FROM invoices;

-- :name get-invoice-by-id :? :1
SELECT * FROM invoices
WHERE id = :id;

-- :name insert-invoice :? :1
INSERT INTO invoices (user_id, schedule, paid)
VALUES (:user-id, :schedule, :paid)
RETURNING id;

-- :name update-invoice-status :! :1
UPDATE invoices
SET paid = TRUE
WHERE id = :id;

-- :name update-invoice-by-id :! :1
UPDATE invoices
SET user_id = :user-id, schedule = :schedule
WHERE id = :id AND paid = FALSE;

-- :name delete-invoice-by-id :! :1
DELETE FROM invoices
WHERE id = :id AND paid = FALSE;