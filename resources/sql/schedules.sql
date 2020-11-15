-- :name create-schedules-table
-- :command :execute
-- :result :raw
-- :doc creates schedules table
CREATE TABLE IF NOT EXISTS schedules (
  id SERIAL PRIMARY KEY,
  film TEXT NOT NULL,
  room TEXT NOT NULL,
  time TEXT NOT NULL,
  seats INTEGER NOT NULL,
  CONSTRAINT fk_film
    FOREIGN KEY (film)
      REFERENCES movies (id),
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp
);

-- :name drop-schedules-table :!
-- :doc drop schedules table
DROP TABLE IF EXISTS schedules;

-- :name get-schedules :? :*
SELECT * FROM schedules;

-- :name get-schedule-by-id :? :1
SELECT * FROM schedules
WHERE id = :id;

-- :name insert-schedule :? :1
INSERT INTO schedules (film, room, time, seats)
VALUES (:film, :room, :time, :seats)
RETURNING id;

-- :name update-schedule-by-id :! :1
UPDATE schedules
SET film = :film, room = :room, time = :time, seats = :seats
WHERE id = :id;

-- :name delete-schedule-by-id :! :1
DELETE FROM schedules WHERE id = :id;
