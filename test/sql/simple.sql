\set ECHO none

\i test/pgxntool/setup.sql

\set df pd.DataFrame.from_dict([{"a":1,"b":"a"},{"a":2,"b":"b"}])

SELECT plan(1);

--SET client_min_messages=debug;
SELECT is(
  E'\n' || repr(
    lambda(
      $l$(
        ndarray
      ) RETURNS ndarray
      LANGUAGE plpythonu
      TRANSFORM FOR TYPE ndarray
      AS $body$
        import pandas as pd

        return $l$ || :'df' || $l$
      $body$
      $l$
      , NULL::ndarray
    )
  )
  , '
   a  b
0  1  a
1  2  b'
  , 'Can represent a dataframe in an ndarray'
);

\i test/pgxntool/finish.sql

-- vi: expandtab sw=2 ts=2
