\set ECHO none

\i test/pgxntool/setup.sql

SELECT plan(
  2 -- all
);

-- all
SELECT is(
    ndall(eval('[[True, False], [False, False]]'::text))::boolean[]
    , array[false]
    , $$ndall('[[True, False], [False, False]]')$$
);
SELECT is(
    ndall(eval('[[True, False], [False, False]]'::text),keepdims:=true)::boolean[]
    , array[false]
    , $$ndall('[[True, False], [False, False]]')$$
);


\i test/pgxntool/finish.sql


-- vi: expandtab sw=2 ts=2

