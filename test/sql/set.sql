\set ECHO none

\i test/pgxntool/setup.sql

SELECT plan(
  2 -- ediff1d
  + 2 -- intersect1d
);

SELECT is(
    pg_temp.nd_as_intarray(ediff1d(pg_temp.test_value()))
    , array[1,1,441]
    , 'ediff1d(test value)'
);
SELECT is(
    pg_temp.nd_as_intarray(ediff1d(pg_temp.test_value(),0::ndarray,99::ndarray))
    , array[99,1,1,441,0]
    , 'ediff1d(test value, 0, 99)'
);


SELECT is(
  intersect1d(pg_temp.test_value(), pg_temp.test_value(2))::int[]
  , '{2,3}'::int[]
  , 'intersect1d()'
);
SELECT is(
  intersect1d(pg_temp.test_value(3), pg_temp.test_value(2))::int[]
  , '{2,3}'::int[]
  , 'intersect1d() with duped values'
);

\i test/pgxntool/finish.sql


-- vi: expandtab sw=2 ts=2
