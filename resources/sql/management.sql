-- :name create-management-table
-- :command :execute
-- :result :raw
-- :doc creates management table
CREATE TABLE IF NOT EXISTS management (
  manager SERIAL NOT NULL,
  theater SERIAL NOT NULL,
  PRIMARY KEY (manager, theater),
  CONSTRAINT fk_manager
    FOREIGN KEY (manager)
      REFERENCES managers (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
  CONSTRAINT fk_theater
    FOREIGN KEY (theater)
      REFERENCES theaters (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp
);

-- :name drop-management-table :!
-- :doc drop management table
DROP TABLE IF EXISTS management;

-- :name get-management :? :*
SELECT * FROM management;

-- :name get-management-by-manager :? :1
SELECT * FROM management
WHERE manager = :manager;

-- :name get-management-by-theater :? :1
SELECT * FROM management
WHERE theater = :theater;

-- :name insert-management :? :1
INSERT INTO management (manager, theater)
VALUES (:manager, :theater)
RETURNING *;

-- :name check-management-exists :? :1
SELECT * FROM management
WHERE manager = :manager
AND theater = :theater;

-- :name delete-management-by-manager-and-theater :! :1
DELETE FROM management
WHERE manager = :manager
AND theater = :theater;
