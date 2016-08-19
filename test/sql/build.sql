\set ECHO none

\i test/pgxntool/psql.sql

BEGIN;
CREATE EXTENSION IF NOT EXISTS plpythonu;

-- Tuple-only because of multiple calls to functions
\t
\i sql/panda_post.sql

\echo # TRANSACTION INTENTIONALLY LEFT OPEN!

-- vi: expandtab sw=2 ts=2
