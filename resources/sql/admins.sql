-- :name create-admins-table
-- :command :execute
-- :result :raw
-- :doc creates admins table
CREATE TABLE IF NOT EXISTS admins (
  id SERIAL PRIMARY KEY,
  password TEXT NOT NULL,
  mail TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp
);

-- :name drop-admins-table :!
-- :doc drop admins table
DROP TABLE IF EXISTS admins;

-- :name get-admins :? :*
SELECT * FROM admins;

-- :name get-admins-without-pass :? :*
SELECT id, mail, created_at FROM admins;

-- :name count-admins :? :1
SELECT COUNT(*) FROM admins;

-- :name get-admin-by-id :? :1
SELECT * FROM admins
WHERE id = :id;

-- :name get-admin-by-mail :? :1
SELECT * FROM admins
WHERE mail = :mail;

-- :name insert-admin :? :1
INSERT INTO admins (password, mail)
VALUES (:password, :mail)
RETURNING *;

-- :name update-admin-by-id :! :1
UPDATE admins
SET password = :password, mail = :mail
WHERE id = :id;

-- :name delete-admin-by-id :! :1
DELETE FROM admins WHERE id = :id;
