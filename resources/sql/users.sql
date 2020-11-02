-- :name create-users-table
-- :command :execute
-- :result :raw
-- :doc creates users table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  first_name TEXT,
  last_name TEXT,
  email TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp
);

-- :name get-users :? :*
SELECT * FROM users;

-- :name get-users-by-id :? :1
SELECT * FROM users
WHERE id = :id;

-- :name insert-users :? :1
INSERT INTO users (first_name, last_name, email)
VALUES (:first-name, :last-name, :email)
RETURNING id;

-- :name update-users-by-id :! :1
UPDATE users
SET first_name = :first-name, last_name = :last-name, email = :email
WHERE id = :id;

-- :name delete-users-by-id :! :1
DELETE FROM users WHERE id = :id;
