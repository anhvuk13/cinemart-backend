-- :name create-movies-table
-- :command :execute
-- :result :raw
-- :doc creates movies table
CREATE TABLE IF NOT EXISTS movies (
  id SERIAL PRIMARY KEY,
  runtime INT,
  genres JSON,
  overview TEXT,
  title TEXT,
  poster_path TEXT,
  backdrop_path TEXT,
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

-- :name draw-movie :? :1
INSERT INTO movies (id, runtime, genres, overview, title, poster_path, backdrop_path)
VALUES (:id, :runtime, :genres, :overview, :title, :poster_path, :backdrop_path)
RETURNING *;

-- :name insert-movie :? :1
INSERT INTO movies (runtime, genres, overview, title, poster_path, backdrop_path)
VALUES (:runtime, :genres, :overview, :title, :poster_path, :backdrop_path)
RETURNING *;

-- :name update-movie-by-id :! :1
UPDATE movies
SET runtime = :runtime, genres = :genres, overview = :overview, title = :title, poster_path = :poster_path, backdrop_path = :backdrop_path
WHERE id = :id;

-- :name delete-movie-by-id :! :1
DELETE FROM movies WHERE id = :id;
