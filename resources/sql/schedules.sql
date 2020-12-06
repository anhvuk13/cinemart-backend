-- :name create-schedules-table
-- :command :execute
-- :result :raw
-- :doc creates schedules table
CREATE TABLE IF NOT EXISTS schedules (
  id SERIAL PRIMARY KEY,
  movie TEXT NOT NULL,
  theater SERIAL NOT NULL,
  room INTEGER NOT NULL,
  seats INTEGER NOT NULL,
  time TEXT NOT NULL,
  CONSTRAINT fk_movie
    FOREIGN KEY (movie)
      REFERENCES movies (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
  CONSTRAINT fk_theater
    FOREIGN KEY (theater)
      REFERENCES theaters (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
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
INSERT INTO schedules (movie, theater, room, seats, time)
VALUES (:movie, :theater, :room, :seats, :time)
RETURNING *;

-- :name update-schedule-by-id :! :1
UPDATE schedules
SET movie = :movie, theater = :theater, room = :room, seats = :seats, time = :time
WHERE id = :id;

-- :name delete-schedule-by-id :! :1
DELETE FROM schedules WHERE id = :id;
