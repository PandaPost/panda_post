\set ECHO none

\i test/pgxntool/setup.sql

SELECT plan(
  0
  + 3 -- all
  + 3 -- any
);

-- all
--SET client_min_messages=debug;
SELECT is(
    ndall(eval('[[True, False], [False, False]]'::text))::boolean -- Will return only a single value
    , false
    , $$ndall('[[True, False], [False, False]]')$$
);
SELECT is(
    ndall(eval('[[True, False], [False, False]]'::text), axis := 1)::boolean[]
    , array[false, false]
    , $$ndall('[[True, False], [False, False]]', axis := 1)$$
);
SELECT is(
    str(ndall(eval('[[True, False], [False, False]]'::text),keepdims:=true))
    , str(eval('[[False]]'))
    , $$ndall('[[True, False], [False, False]]', keepdims := true)$$
);

-- any
SELECT is(
    ndany(eval('[[True, False], [False, False]]'::text))::boolean -- Will return only a single value
    , true
    , $$ndany('[[True, False], [False, False]]')$$
);
SELECT is(
    ndany(eval('[[True, False], [False, False]]'::text), axis := 1)::boolean[]
    , array[true,false]
    , $$ndany('[[True, False], [False, False]]', axis := 1)$$
);
--SET client_min_messages=debug;
SELECT is(
    str(ndany(eval('[[True, False], [False, False]]'::text),keepdims:=true))
    , str(eval('[[True]]'))
    , $$ndany('[[True, False], [False, False]]', keepdims := true)$$
);


\i test/pgxntool/finish.sql


-- vi: expandtab sw=2 ts=2

