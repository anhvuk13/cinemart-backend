-- :name create-users-table
-- :command :execute
-- :result :raw
-- :doc creates users table
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  fullname TEXT NOT NULL,
  dob TEXT NOT NULL,
  gender TEXT NOT NULL,
  mail TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp
);

-- :name drop-users-table :!
-- :doc drop users table
DROP TABLE IF EXISTS users;

-- :name get-users :? :*
SELECT * FROM users;

-- :name get-user-by-id :? :1
SELECT * FROM users
WHERE id = :id;

-- :name insert-user :? :1
INSERT INTO users (fullname, dob, gender, mail)
VALUES (:fullname, :dob, :gender, :mail)
RETURNING id;

-- :name update-user-by-id :! :1
UPDATE users
SET fullname = :fullname, dob = :dob, gender = :gender, mail = :mail
WHERE id = :id;

-- :name delete-user-by-id :! :1
DELETE FROM users WHERE id = :id;
