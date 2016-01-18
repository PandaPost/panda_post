\set ECHO none

\i test/pgxntool/setup.sql

CREATE FUNCTION pg_temp.test_value(
) RETURNS ndarray
TRANSFORM FOR TYPE ndarray
LANGUAGE plpythonu IMMUTABLE AS $body$
  import numpy as np

  return np.array([1,2,3,444]) # 444 is big enough to test endianness
$body$;
CREATE FUNCTION pg_temp.nd_as_intarray(
  i ndarray
) RETURNS int[]
TRANSFORM FOR TYPE ndarray
LANGUAGE plpythonu AS $body$
  import numpy as np

  return i.tolist()
$body$;

CREATE TEMP TABLE nd(
  nd ndarray
);

INSERT INTO nd SELECT pg_temp.test_value();

SELECT * FROM nd;

SELECT pg_temp.nd_as_intarray(nd) FROM nd;

\echo # TRANSACTION INTENTIONALLY LEFT OPEN!

-- vi: expandtab sw=2 ts=2
