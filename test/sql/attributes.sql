\set ECHO none

\i test/pgxntool/setup.sql

SELECT plan(
  1 -- T
);

-- ediff1d
SELECT is(
    str("T"(eval('[[1,2],[3,4]]')))
    , '[[1 3]
 [2 4]]'
    , 'T([[1,2],[3,4]])'
);


\i test/pgxntool/finish.sql


-- vi: expandtab sw=2 ts=2
