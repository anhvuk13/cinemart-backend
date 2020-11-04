-- :name create-tickets-table
-- :command :execute
-- :result :raw
-- :doc creates tickets table
CREATE TABLE IF NOT EXISTS tickets (
  user_id SERIAL NOT NULL,
  schedule_id INTEGER NOT NULL,
  seat SERIAL NOT NULL,
  PRIMARY KEY (user_id, schedule_id, seat),
  CONSTRAINT fk_user
    FOREIGN KEY (user_id)
      REFERENCES users (id),
  CONSTRAINT fk_schedule
    FOREIGN KEY (schedule_id)
      REFERENCES schedules (id),
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp
);

-- :name drop-tickets-table :!
-- :doc drop tickets table
DROP TABLE IF EXISTS tickets;

-- :name get-tickets :? :*
SELECT * FROM tickets;

-- :name get-ticket-by-id :? :1
SELECT * FROM tickets
WHERE id = :id;

-- :name insert-ticket :? :1
INSERT INTO tickets (user_id, schedule_id, seat)
VALUES (:user-id, :schedule-id, :seat)
RETURNING id;

-- :name update-ticket-by-id :! :1
UPDATE tickets
SET user_id = :user-id, schedule_id = :schedule-id, seat = :seat
WHERE id = :id;

-- :name delete-ticket-by-id :! :1
DELETE FROM tickets WHERE id = :id;
