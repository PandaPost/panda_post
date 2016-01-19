\set ECHO none

\i test/pgxntool/setup.sql

\set df pd.DataFrame.from_dict([{"a":1,"b":"a"},{"a":2,"b":"b"}])

SELECT plan(2);

--SET client_min_messages=debug;
SELECT lives_ok(
  format(
    $fmt$
    CREATE TEMP TABLE df AS SELECT
    lambda(
      $l$(ndarray) RETURNS ndarray LANGUAGE plpythonu TRANSFORM FOR TYPE ndarray AS $body$
        import pandas as pd

        return %s
        $body$
      $l$
      , NULL::ndarray
    ) AS nd
    $fmt$
    , :'df'
  )
  , 'Create temp table'
);

SELECT is(
      E'\n' || repr(nd)
      , '
   a  b
0  1  a
1  2  b'
    )
  FROM df
;

\i test/pgxntool/finish.sql

-- vi: expandtab sw=2 ts=2
