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
DROP TYPE IF EXISTS genre;
CREATE TYPE genre AS (
  id INT,
  name TEXT
);

-- :name drop-movies-table :!
-- :doc drop movies table
DROP TABLE IF EXISTS movies;

-- :name get-movies :? :*
SELECT * FROM movies
ORDER BY created_at DESC;

-- :name get-movies-this-month :? :*
SELECT DISTINCT ON(m.id) m.* FROM movies m
INNER JOIN schedules s ON m.id = s.movie
WHERE s.time > now()
AND extract(year from s.time) = extract(year from now())
AND extract(month from s.time) = extract(month from now());

-- :name get-movies-this-week :? :*
SELECT DISTINCT ON(m.id) m.* FROM movies m
INNER JOIN schedules s ON m.id = s.movie
WHERE s.time > now()
AND extract(year from s.time) = extract(year from now())
AND extract(month from s.time) = extract(month from now())
AND extract(week from s.time) = extract(week from now());

-- :name get-movies-this-day :? :*
SELECT DISTINCT ON(m.id) m.* FROM movies m
INNER JOIN schedules s ON m.id = s.movie
WHERE s.time > now()
AND extract(year from s.time) = extract(year from now())
AND extract(month from s.time) = extract(month from now())
AND extract(week from s.time) = extract(week from now())
AND extract(day from s.time) = extract(day from now());

-- :name get-movies-by-theater :? :*
SELECT DISTINCT ON(m.id) m.* FROM movies m
INNER JOIN schedules s ON m.id = s.movie
INNER JOIN theaters t ON s.theater = t.id
WHERE t.id = :id;

-- :name get-movies-this-month-by-theater :? :*
SELECT DISTINCT ON(m.id) m.* FROM movies m
INNER JOIN schedules s ON m.id = s.movie
INNER JOIN theaters t ON s.theater = t.id
WHERE t.id = :id
AND s.time > now()
AND extract(year from s.time) = extract(year from now())
AND extract(month from s.time) = extract(month from now());

-- :name get-movies-this-week-by-theater :? :*
SELECT DISTINCT ON(m.id) m.* FROM movies m
INNER JOIN schedules s ON m.id = s.movie
INNER JOIN theaters t ON s.theater = t.id
WHERE t.id = :id
AND s.time > now()
AND extract(year from s.time) = extract(year from now())
AND extract(month from s.time) = extract(month from now())
AND extract(week from s.time) = extract(week from now());

-- :name get-movies-this-day-by-theater :? :*
SELECT DISTINCT ON(m.id) m.* FROM movies m
INNER JOIN schedules s ON m.id = s.movie
INNER JOIN theaters t ON s.theater = t.id
WHERE t.id = :id
AND s.time > now()
AND extract(year from s.time) = extract(year from now())
AND extract(month from s.time) = extract(month from now())
AND extract(week from s.time) = extract(week from now())
AND extract(day from s.time) = extract(day from now());

-- :name get-latest-movies :? :*
SELECT * FROM movies
ORDER BY created_at DESC
LIMIT :count;

-- :name get-movies-by-genre :? :*
SELECT DISTINCT ON(id) id, runtime, genres, overview, title, poster_path, backdrop_path
FROM (
  SELECT *, json_array_elements(genres) genre FROM movies
) t
WHERE CAST (genre ->> 'id' AS INTEGER) = :id;

-- :name get-genres :? :*
select distinct * from json_populate_recordset(
  null::genre, (
    select json_agg(g) g from (
      select json_array_elements(genres) g from movies
    ) t
  )
);

-- :name get-genre-by-id :? :1
select distinct * from json_populate_recordset(
  null::genre, (
    select json_agg(g) g from (
      select json_array_elements(genres) g from movies
    ) t
  )
)
where id = :id;

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
