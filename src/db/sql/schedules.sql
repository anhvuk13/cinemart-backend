-- :name create-schedules-table
-- :command :execute
-- :result :raw
-- :doc creates schedules table
CREATE TABLE IF NOT EXISTS schedules (
  id SERIAL PRIMARY KEY,
  movie SERIAL NOT NULL,
  theater SERIAL NOT NULL,
  room INTEGER NOT NULL,
  nrow INTEGER NOT NULL,
  ncolumn INTEGER NOT NULL,
  price INTEGER NOT NULL,
  time TEXT NOT NULL,
  reserved INTEGER DEFAULT 0,
  CONSTRAINT fk_movie
    FOREIGN KEY (movie)
      REFERENCES movies (id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
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
SELECT * from schedules;

-- :name get-schedules-by-theater :? :*
SELECT * FROM schedules
WHERE theater = :theater;

-- :name get-schedule-by-id :? :1
SELECT * FROM schedules
WHERE id = :id;

-- :name insert-schedule :? :1
INSERT INTO schedules (movie, theater, room, nrow, ncolumn, price, time)
VALUES (:movie, :theater, :room, :nrow, :ncolumn, :price, :time)
RETURNING *;

-- :name delete-schedule-by-id :! :1
DELETE FROM schedules WHERE id = :id;
