\i test/pgxntool/psql.sql

CREATE SCHEMA IF NOT EXISTS tap;
SET search_path = public, tap;
CREATE EXTENSION IF NOT EXISTS pgtap SCHEMA tap;
\pset format unaligned
\pset tuples_only true
\pset pager
