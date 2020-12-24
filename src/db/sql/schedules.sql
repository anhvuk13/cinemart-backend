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
SELECT s.id, s.room, s.nrow, s.ncolumn, s.price, s.time, s.reserved, s.created_at,
array_agg(t.seat) reserved_seats, array_agg(t.seat_name) reserved_seats_name,
m.id movie_id, m.runtime movie_runtime, m.genres movie_genres, m.overview movie_overview,
m.title movie_title, m.poster_path movie_poster_path, m.backdrop_path movie_backdrop_path,
th.id theater_id, th.name theater_name, th.address theater_address
FROM schedules s
FULL OUTER JOIN invoices i ON i.schedule = s.id
FULL OUTER JOIN tickets t ON t.invoice = i.id
INNER JOIN movies m ON s.movie = m.id
INNER JOIN theaters th ON s.theater = th.id
GROUP BY s.id, s.room, s.nrow, s.ncolumn, s.price, s.time, s.reserved, s.created_at,
movie_id, movie_runtime, movie_overview, movie_title, movie_poster_path, movie_backdrop_path,
theater_id, theater_name, theater_address
ORDER BY s.time DESC;

-- :name get-schedules-by-week :? :*
SELECT s.id, s.room, s.nrow, s.ncolumn, s.price, s.time, s.reserved, s.created_at,
array_agg(t.seat) reserved_seats, array_agg(t.seat_name) reserved_seats_name,
m.id movie_id, m.runtime movie_runtime, m.genres movie_genres, m.overview movie_overview,
m.title movie_title, m.poster_path movie_poster_path, m.backdrop_path movie_backdrop_path,
th.id theater_id, th.name theater_name, th.address theater_address
FROM schedules s
FULL OUTER JOIN invoices i ON i.schedule = s.id
FULL OUTER JOIN tickets t ON t.invoice = i.id
INNER JOIN movies m ON s.movie = m.id
INNER JOIN theaters th ON s.theater = th.id
WHERE extract(year from s.time) = :year
AND extract(month from s.time) = :month
AND extract(week from s.time) = :week
GROUP BY s.id, s.room, s.nrow, s.ncolumn, s.price, s.time, s.reserved, s.created_at,
movie_id, movie_runtime, movie_overview, movie_title, movie_poster_path, movie_backdrop_path,
theater_id, theater_name, theater_address
ORDER BY s.time DESC;

-- :name get-schedules-by-date :? :*
SELECT s.id, s.room, s.nrow, s.ncolumn, s.price, s.time, s.reserved, s.created_at,
array_agg(t.seat) reserved_seats, array_agg(t.seat_name) reserved_seats_name,
m.id movie_id, m.runtime movie_runtime, m.genres movie_genres, m.overview movie_overview,
m.title movie_title, m.poster_path movie_poster_path, m.backdrop_path movie_backdrop_path,
th.id theater_id, th.name theater_name, th.address theater_address
FROM schedules s
FULL OUTER JOIN invoices i ON i.schedule = s.id
FULL OUTER JOIN tickets t ON t.invoice = i.id
INNER JOIN movies m ON s.movie = m.id
INNER JOIN theaters th ON s.theater = th.id
WHERE extract(year from s.time) = :year
AND extract(month from s.time) = :month
AND extract(week from s.time) = :week
AND extract(day from s.time) = :day
GROUP BY s.id, s.room, s.nrow, s.ncolumn, s.price, s.time, s.reserved, s.created_at,
movie_id, movie_runtime, movie_overview, movie_title, movie_poster_path, movie_backdrop_path,
theater_id, theater_name, theater_address
ORDER BY s.time DESC;

-- :name get-schedules-by-theater :? :*
SELECT s.id, s.room, s.nrow, s.ncolumn, s.price, s.time, s.reserved, s.created_at,
array_agg(t.seat) reserved_seats, array_agg(t.seat_name) reserved_seats_name,
m.id movie_id, m.runtime movie_runtime, m.genres movie_genres, m.overview movie_overview,
m.title movie_title, m.poster_path movie_poster_path, m.backdrop_path movie_backdrop_path,
th.id theater_id, th.name theater_name, th.address theater_address
FROM schedules s
FULL OUTER JOIN invoices i ON i.schedule = s.id
FULL OUTER JOIN tickets t ON t.invoice = i.id
INNER JOIN movies m ON s.movie = m.id
INNER JOIN theaters th ON s.theater = th.id
WHERE s.theater = :theater
GROUP BY s.id, s.room, s.nrow, s.ncolumn, s.price, s.time, s.reserved, s.created_at,
movie_id, movie_runtime, movie_overview, movie_title, movie_poster_path, movie_backdrop_path,
theater_id, theater_name, theater_address
ORDER BY s.time DESC;

-- :name get-schedules-by-theater-and-movie :? :*
SELECT s.id, s.room, s.nrow, s.ncolumn, s.price, s.time, s.reserved, s.created_at,
array_agg(t.seat) reserved_seats, array_agg(t.seat_name) reserved_seats_name,
m.id movie_id, m.runtime movie_runtime, m.genres movie_genres, m.overview movie_overview,
m.title movie_title, m.poster_path movie_poster_path, m.backdrop_path movie_backdrop_path,
th.id theater_id, th.name theater_name, th.address theater_address
FROM schedules s
FULL OUTER JOIN invoices i ON i.schedule = s.id
FULL OUTER JOIN tickets t ON t.invoice = i.id
INNER JOIN movies m ON s.movie = m.id
INNER JOIN theaters th ON s.theater = th.id
WHERE th.id = :id AND m.id = :movie
GROUP BY s.id, s.room, s.nrow, s.ncolumn, s.price, s.time, s.reserved, s.created_at,
movie_id, movie_runtime, movie_overview, movie_title, movie_poster_path, movie_backdrop_path,
theater_id, theater_name, theater_address
ORDER BY s.time DESC;

-- :name get-schedule-by-id :? :1
--SELECT * FROM schedules
--WHERE id = :id;
SELECT s.id, s.room, s.nrow, s.ncolumn, s.price, s.time, s.reserved, s.created_at,
array_agg(t.seat) reserved_seats, array_agg(t.seat_name) reserved_seats_name,
m.id movie_id, m.runtime movie_runtime, m.genres movie_genres, m.overview movie_overview,
m.title movie_title, m.poster_path movie_poster_path, m.backdrop_path movie_backdrop_path,
th.id theater_id, th.name theater_name, th.address theater_address
FROM schedules s
FULL OUTER JOIN invoices i ON i.schedule = s.id
FULL OUTER JOIN tickets t ON t.invoice = i.id
INNER JOIN movies m ON s.movie = m.id
INNER JOIN theaters th ON s.theater = th.id
WHERE s.id = :id
GROUP BY s.id, s.room, s.nrow, s.ncolumn, s.price, s.time, s.reserved, s.created_at,
movie_id, movie_runtime, movie_overview, movie_title, movie_poster_path, movie_backdrop_path,
theater_id, theater_name, theater_address;

-- :name insert-schedule :? :1
INSERT INTO schedules (movie, theater, room, nrow, ncolumn, price, time)
VALUES (:movie, :theater, :room, :nrow, :ncolumn, :price, :time)
RETURNING *;

-- :name delete-schedule-by-id :! :1
DELETE FROM schedules WHERE id = :id;
