-- :name create-managers-table
-- :command :execute
-- :result :raw
-- :doc creates managers table
CREATE TABLE IF NOT EXISTS managers (
  id SERIAL PRIMARY KEY,
  password TEXT NOT NULL,
  mail TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp
);

-- :name drop-managers-table :!
-- :doc drop managers table
DROP TABLE IF EXISTS managers;

-- :name get-managers :? :*
SELECT * FROM managers;

-- :name get-managers-without-pass :? :*
SELECT mr.id, mr.mail, mr.created_at,
t.id as theater_id, t.name as theater_name
FROM managers as mr
inner join management as mt on mr.id = mt.manager
inner join theaters as t on mt.theater = t.id;

-- :name get-managers-by-theater :? :*
SELECT mr.id, mr.mail, mr.created_at
FROM managers mr
inner join management mt on mr.id = mt.manager
inner join theaters t on mt.theater = t.id
WHERE t.id = :theater;

-- :name get-manager-by-id :? :1
SELECT mr.id, mr.mail, mr.password, mr.created_at,
t.id theater_id,
t.name theater_name,
t.address theater_address
FROM managers mr
FULL OUTER JOIN management mt ON mr.id = mt.manager
FULL OUTER JOIN theaters t ON mt.theater = t.id
WHERE mr.id = :id;

-- :name get-manager-by-mail :? :1
SELECT mr.id, mr.mail, mr.password, mr.created_at,
t.id theater_id,
t.name theater_name,
t.address theater_address
FROM managers mr
FULL OUTER JOIN management mt ON mr.id = mt.manager
FULL OUTER JOIN theaters t ON mt.theater = t.id
WHERE mr.mail = :mail;

-- :name insert-manager :? :1
INSERT INTO managers (password, mail)
VALUES (:password, :mail)
RETURNING *;

-- :name update-manager-by-id :! :1
UPDATE managers
SET password = :password, mail = :mail
WHERE id = :id;

-- :name delete-manager-by-id :! :1
DELETE FROM managers WHERE id = :id;
