\set ECHO none

\i test/pgxntool/setup.sql

SELECT plan(
  2 -- ediff1d
  + 2 -- intersect1d
  + 1 -- setxor1d
  + 1 -- union1d
  + 1 -- setdiff1d
  + 2 -- in1d
);

-- ediff1d
SELECT is(
    ediff1d(pg_temp.test_value())::int[]
    , array[1,1,441]
    , 'ediff1d(test value)'
);
SELECT is(
    ediff1d(pg_temp.test_value(),0::ndarray,99::ndarray)::int[]
    , array[99,1,1,441,0]
    , 'ediff1d(test value, 0, 99)'
);

-- intersect1d
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

-- setxor1d
SELECT is(
  setxor1d(array[1,1,2,2]::ndarray,array[2,3]::ndarray)::int[]
  , array[1,3]
  , 'setxor1d()'
);

-- union1d
SELECT is(
  union1d(array[2, 3, 2, 4, 1]::ndarray,array[3,4,5,6]::ndarray)::int[]
  , array[1,2,3,4,5,6]
  , 'union1d()'
);

-- setdiff1d
SELECT is(
  setdiff1d(array[1, 2, 3, 2, 4, 1]::ndarray,array[3,4,5,6]::ndarray)::int[]
  , array[1,2]
  , 'setdiff1d()'
);

-- in1d
SELECT is(
  in1d(array[2, 3, 2, 4, 1]::ndarray,array[3,2,5,6]::ndarray)::boolean[]
  , array[True,True,True,False,False]
  , 'in1d()'
);
SELECT is(
  in1d(array[2, 3, 2, 4, 1]::ndarray,array[3,2,5,6]::ndarray,invert:=true)::boolean[]
  , array[False,False,False,True,True]
  , 'in1d(invert=true)'
);

\i test/pgxntool/finish.sql


-- vi: expandtab sw=2 ts=2
