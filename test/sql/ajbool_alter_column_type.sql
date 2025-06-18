BEGIN;
-- setup table with data and index
CREATE TABLE alter_test (i int, state bool, PRIMARY KEY (i, state));
INSERT INTO alter_test
SELECT i,
    (CASE i%2
            WHEN 0 THEN true
            WHEN 1 THEN false
    END)::bool
FROM generate_series(1,1e4) i;

-- alter table to new type
SET client_min_messages = debug1;
ALTER TABLE alter_test ALTER COLUMN state TYPE ajbool;
RESET client_min_messages;

ROLLBACK;

