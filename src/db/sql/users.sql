-- :name create-users-table
-- :command :execute
-- :result :raw
-- :doc creates users table
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  fullname TEXT NOT NULL,
  dob TIMESTAMP NOT NULL,
  username TEXT NOT NULL,
  password TEXT NOT NULL,
  mail TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp
);

-- :name drop-users-table :!
-- :doc drop users table
DROP TABLE IF EXISTS users;

-- :name get-users :? :*
SELECT * FROM users;

-- :name get-users-without-pass :? :*
SELECT id, fullname, dob, username, mail, created_at FROM users;

-- :name get-user-by-id :? :1
SELECT * FROM users
WHERE id = :id;

-- :name get-user-by-mail :? :1
SELECT * FROM users
WHERE mail = :mail;

-- :name insert-user :? :1
INSERT INTO users (fullname, dob, username, password, mail)
VALUES (:fullname, :dob, :username, :password, :mail)
RETURNING *;

-- :name update-user-by-id :! :1
UPDATE users
SET fullname = :fullname, dob = :dob, username = :username, password = :password, mail = :mail
WHERE id = :id;

-- :name delete-user-by-id :! :1
DELETE FROM users WHERE id = :id;

-- :name create-test :!
CREATE TABLE IF NOT EXISTS test (
  j json
);

-- :name insert-test :1 :1
INSERT INTO test (j)
VALUES (:j)
RETURNING *;
