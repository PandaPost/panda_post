\set ECHO none

\i test/pgxntool/setup.sql

SELECT plan(
  2 -- all
);

-- all
SELECT is(
    ndall(eval('[[True, False], [False, False]]'::text))::boolean
    , false
    , $$ndall('[[True, False], [False, False]]')$$
);
--SET client_min_messages=debug;
SELECT is(
    str(ndall(eval('[[True, False], [False, False]]'::text),keepdims:=true))
    , str(eval('[[False]]'))
    , $$ndall('[[True, False], [False, False]]', keepdims := true)$$
);


\i test/pgxntool/finish.sql


-- vi: expandtab sw=2 ts=2

