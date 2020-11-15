-- :name create-movies-table
-- :command :execute
-- :result :raw
-- :doc creates movies table
CREATE TABLE IF NOT EXISTS movies (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  poster TEXT,
  length  INT,
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp
);

-- :name drop-movies-table :!
-- :doc drop movies table
DROP TABLE IF EXISTS movies;

-- :name get-movies :? :*
SELECT * FROM movies;

-- :name get-movie-by-id :? :1
SELECT * FROM movies
WHERE id = :id;

-- :name insert-movie :? :1
INSERT INTO movies (name, poster, length)
VALUES (:name, :poster, :length)
RETURNING id;

-- :name update-movie-by-id :! :1
UPDATE movies
SET name = :name, poster = :poster, length = :length
WHERE id = :id;

-- :name delete-movie-by-id :! :1
DELETE FROM movies WHERE id = :id;
