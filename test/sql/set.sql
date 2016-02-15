\set ECHO none

\i test/pgxntool/setup.sql

SELECT plan(2);

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

\i test/pgxntool/finish.sql


-- vi: expandtab sw=2 ts=2
