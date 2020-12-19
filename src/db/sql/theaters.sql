-- :name create-theaters-table
-- :command :execute
-- :result :raw
-- :doc creates theaters table
CREATE TABLE IF NOT EXISTS theaters (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  address TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp
);

-- :name drop-theaters-table :!
-- :doc drop theaters table
DROP TABLE IF EXISTS theaters;

-- :name get-theaters :? :*
SELECT * FROM theaters;

-- :name get-theater-by-id :? :1
SELECT * FROM theaters
WHERE id = :id;

-- :name get-theaters-by-movie :? :*
SELECT DISTINCT t.id, t.name, t.address, t.created_at FROM theaters t
INNER JOIN schedules s ON s.theater = t.id
INNER JOIN movies m ON s.movie = m.id
WHERE m.id = :id;

-- :name insert-theater :? :1
INSERT INTO theaters (name, address)
VALUES (:name, :address)
RETURNING *;

-- :name update-theater-by-id :! :1
UPDATE theaters
SET name = :name, address = :address
WHERE id = :id;

-- :name delete-theater-by-id :! :1
DELETE FROM theaters WHERE id = :id;
