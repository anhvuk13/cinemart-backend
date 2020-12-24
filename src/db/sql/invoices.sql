-- :name create-invoices-table
-- :command :execute
-- :result :raw
-- :doc creates invoices table
CREATE TABLE IF NOT EXISTS invoices (
  id SERIAL PRIMARY KEY,
  user_id SERIAL NOT NULL,
  schedule SERIAL NOT NULL,
  paid BOOL NOT NULL DEFAULT FALSE,
  tickets_count INTEGER DEFAULT 0,
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
        ON DELETE NO ACTION,
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp
);
CREATE OR REPLACE FUNCTION update_invoices_trigger()
  RETURNS TRIGGER
  LANGUAGE PLPGSQL
  AS
$$
BEGIN
  update schedules
  set reserved = reserved - old.tickets_count + new.tickets_count
  where schedules.id = new.schedule;
  RETURN NEW;
END;
$$;
CREATE OR REPLACE FUNCTION delete_invoices_trigger()
  RETURNS TRIGGER
  LANGUAGE PLPGSQL
  AS
$$
BEGIN
  update schedules
  set reserved = reserved - old.tickets_count
  where schedules.id = old.schedule;
  RETURN OLD;
END;
$$;
DROP TRIGGER IF EXISTS tg_update_invoices ON invoices;
DROP TRIGGER IF EXISTS tg_delete_invoices ON invoices;
CREATE TRIGGER tg_update_invoices
  AFTER UPDATE
  ON invoices
  FOR EACH ROW
  EXECUTE PROCEDURE update_invoices_trigger();
CREATE TRIGGER tg_delete_invoices
  AFTER DELETE
  ON invoices
  FOR EACH ROW
  EXECUTE PROCEDURE delete_invoices_trigger();

-- :name drop-invoices-table :!
-- :doc drop invoices table
DROP TABLE IF EXISTS invoices;

-- :name get-invoices :? :*
--SELECT * FROM invoices;
SELECT i.id, i.user_id, i.schedule, i.paid, i.cost, i.tickets_count, i.created_at,
array_agg(t.seat) seats, array_agg(t.seat_name) seats_name,
m.id movie_id, m.runtime movie_runtime, m.genres movie_genres, m.overview movie_overview, m.title movie_title, m.poster_path movie_poster_path, m.backdrop_path movie_backdrop_path, s.id schedule_id, s.room schedule_room, s.nrow schedule_nrow, s.ncolumn schedule_ncolumn, s.time schedule_time, s.reserved schedule_reserved, th.id theater_id, th.name theater_name, th.address theater_address
FROM invoices i
FULL OUTER JOIN tickets t ON t.invoice = i.id
INNER JOIN schedules s ON i.schedule = s.id
INNER JOIN theaters th ON s.theater = th.id
INNER JOIN movies m ON s.movie = m.id
GROUP BY i.id, i.user_id, i.schedule, i.paid, i.cost, i.tickets_count, i.created_at,
movie_id, movie_runtime, movie_overview, movie_title, movie_poster_path, movie_backdrop_path, schedule_id, schedule_room, schedule_nrow, schedule_ncolumn, schedule_time, schedule_reserved, theater_id, theater_name, theater_address
ORDER BY created_at DESC;

-- :name get-invoices-by-user :? :*
--SELECT * FROM invoices
--WHERE user_id = :user_id;
SELECT i.id, i.user_id, i.schedule, i.paid, i.cost, i.tickets_count, i.created_at,
array_agg(t.seat) seats, array_agg(t.seat_name) seats_name,
m.id movie_id, m.runtime movie_runtime, m.genres movie_genres, m.overview movie_overview, m.title movie_title, m.poster_path movie_poster_path, m.backdrop_path movie_backdrop_path, s.id schedule_id, s.room schedule_room, s.nrow schedule_nrow, s.ncolumn schedule_ncolumn, s.time schedule_time, s.reserved schedule_reserved, th.id theater_id, th.name theater_name, th.address theater_address
FROM invoices i
FULL OUTER JOIN tickets t ON t.invoice = i.id
INNER JOIN schedules s ON i.schedule = s.id
INNER JOIN theaters th ON s.theater = th.id
INNER JOIN movies m ON s.movie = m.id
WHERE user_id = :user_id
GROUP BY i.id, i.user_id, i.schedule, i.paid, i.cost, i.tickets_count, i.created_at,
movie_id, movie_runtime, movie_overview, movie_title, movie_poster_path, movie_backdrop_path, schedule_id, schedule_room, schedule_nrow, schedule_ncolumn, schedule_time, schedule_reserved, theater_id, theater_name, theater_address
ORDER BY created_at DESC;

-- :name get-invoice-by-id :? :1
--SELECT * FROM invoices
--WHERE id = :id;
SELECT i.id, i.user_id, i.schedule, i.paid, i.cost, i.tickets_count, i.created_at,
array_agg(t.seat) seats, array_agg(t.seat_name) seats_name,
m.id movie_id, m.runtime movie_runtime, m.genres movie_genres, m.overview movie_overview, m.title movie_title, m.poster_path movie_poster_path, m.backdrop_path movie_backdrop_path, s.id schedule_id, s.room schedule_room, s.nrow schedule_nrow, s.ncolumn schedule_ncolumn, s.time schedule_time, s.reserved schedule_reserved, th.id theater_id, th.name theater_name, th.address theater_address
FROM invoices i
FULL OUTER JOIN tickets t ON t.invoice = i.id
INNER JOIN schedules s ON i.schedule = s.id
INNER JOIN theaters th ON s.theater = th.id
INNER JOIN movies m ON s.movie = m.id
WHERE i.id = :id
GROUP BY i.id, i.user_id, i.schedule, i.paid, i.cost, i.tickets_count, i.created_at,
movie_id, movie_runtime, movie_overview, movie_title, movie_poster_path, movie_backdrop_path, schedule_id, schedule_room, schedule_nrow, schedule_ncolumn, schedule_time, schedule_reserved, theater_id, theater_name, theater_address;

-- :name insert-invoice :? :1
INSERT INTO invoices (user_id, schedule)
VALUES (:user_id, :schedule)
RETURNING *;

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
