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
  time TIMESTAMP NOT NULL,
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
SELECT * FROM schedules;

-- :name get-schedules-by-theater :? :*
SELECT * FROM schedules
WHERE theater = :theater;

-- :name get-schedule-by-id :? :1
--SELECT * FROM schedules
--WHERE id = :id;
SELECT s.id, s.movie, s.theater, s.nrow, s.ncolumn, s.price, s.time, s.reserved, s.created_at,
array_agg(t.seat) reserved_seats, array_agg(t.seat_name) reserved_seats_name
FROM schedules s
FULL OUTER JOIN invoices i ON i.schedule = s.id
FULL OUTER JOIN tickets t ON t.invoice = i.id
WHERE s.id = :id
GROUP BY s.id, s.movie, s.theater, s.nrow, s.ncolumn, s.price, s.time, s.reserved, s.created_at;

-- :name insert-schedule :? :1
INSERT INTO schedules (movie, theater, room, nrow, ncolumn, price, time)
VALUES (:movie, :theater, :room, :nrow, :ncolumn, :price, :time)
RETURNING *;

-- :name delete-schedule-by-id :! :1
DELETE FROM schedules WHERE id = :id;
