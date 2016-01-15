\set ECHO none

\i test/pgxntool/psql.sql

BEGIN;

\i sql/PandaPost.sql

\echo # TRANSACTION INTENTIONALLY LEFT OPEN!

-- vi: expandtab sw=2 ts=2
