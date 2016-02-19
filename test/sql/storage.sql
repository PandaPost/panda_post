\set ECHO none

\i test/pgxntool/setup.sql

CREATE TEMP TABLE nd(
  nd ndarray
);

INSERT INTO nd SELECT pg_temp.test_value();

SELECT * FROM nd;

SELECT nd::int[] FROM nd;

\echo # TRANSACTION INTENTIONALLY LEFT OPEN!

-- vi: expandtab sw=2 ts=2
