-- :name create-auth-table
-- :command :execute
-- :result :raw
-- :doc creates auth table
CREATE TABLE IF NOT EXISTS auth (
  token TEXT NOT NULL,
  refresh_token TEXT NOT NULL,
  PRIMARY KEY (token, refresh_token),
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp
);

-- :name drop-auth-table :!
-- :doc drop auth table
DROP TABLE IF EXISTS auth;

-- :name get-auth :? :*
SELECT * FROM auth;

-- :name get-auth-by-token :? :1
SELECT * FROM auth
WHERE token = :token;

-- :name get-auth-by-refresh-token :? :1
SELECT * FROM auth
WHERE refresh_token = :refresh-token;

-- :name insert-auth :? :1
INSERT INTO auth (token, refresh_token)
VALUES (:token, :refresh-token)
RETURNING *;

-- :name delete-auth-by-token :! :n
DELETE FROM auth
WHERE token = :token;

-- :name delete-auth-by-refresh-token :! :n
DELETE FROM auth
WHERE refresh_token = :refresh-token;
