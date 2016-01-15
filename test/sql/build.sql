\set ECHO none

\i test/pgxntool/psql.sql

BEGIN;
CREATE EXTENSION IF NOT EXISTS plpythonu;

\i sql/PandaPost.sql

\echo # TRANSACTION INTENTIONALLY LEFT OPEN!

-- vi: expandtab sw=2 ts=2
