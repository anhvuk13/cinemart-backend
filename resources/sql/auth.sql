-- :name create-auth-table
-- :command :execute
-- :result :raw
-- :doc creates auth table
CREATE TABLE IF NOT EXISTS auth (
  user_id SERIAL NOT NULL,
  token TEXT NOT NULL,
  refresh_token TEXT NOT NULL,
  PRIMARY KEY (user_id, token, refresh_token),
  CONSTRAINT fk_user
    FOREIGN KEY (user_id)
      REFERENCES users (id),
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp
);

-- :name drop-auth-table :!
-- :doc drop auth table
DROP TABLE IF EXISTS auth;

-- :name count-auth :? :1
SELECT COUNT(*) FROM auth
WHERE user_id = :user-id;

-- :name get-auth :? :*
SELECT * FROM auth
WHERE user_id = :user-id
AND token = :token
AND refresh_token = :refresh-token;

-- :name get-auth-by-user-id :? :*
SELECT * FROM auth
WHERE user_id = :user-id;

-- :name get-auth-by-token :? :*
SELECT * FROM auth
WHERE token = :token;

-- :name get-auth-by-refresh-token :? :*
SELECT * FROM auth
WHERE refresh_token = :refresh-token;

-- :name insert-auth :? :1
INSERT INTO auth (user_id, token, refresh_token)
VALUES (:user-id, :token, :refresh-token)
RETURNING *;

-- :name delete-auth-by-user-id :! :n
DELETE FROM auth WHERE user_id = :user-id;

-- :name delete-auth-by-token :! :n
DELETE FROM auth
WHERE user_id = :user-id
AND token = :token;

-- :name delete-auth-by-refresh-token :! :n
DELETE FROM auth
WHERE user_id = :user-id
AND refresh_token = :refresh-token;

-- :name delete-all-but-current-auth :! :n
DELETE FROM auth
WHERE user_id = :user-id
AND token != :token
AND refresh_token != :refresh-token;
