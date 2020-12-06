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
SELECT id, mail, created_at FROM managers;

-- :name get-manager-by-id :? :1
SELECT * FROM managers
WHERE id = :id;

-- :name get-manager-by-mail :? :1
SELECT * FROM managers
WHERE mail = :mail;

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
