-- Add any test dependency statements here
CREATE EXTENSION IF NOT EXISTS plpythonu;
CREATE EXTENSION IF NOT EXISTS lambda;
CREATE EXTENSION PandaPost;

-- General test infrastructure (should maybe be in it's own file)
CREATE FUNCTION pg_temp.test_value(
  version int DEFAULT 1
) RETURNS ndarray
TRANSFORM FOR TYPE ndarray
LANGUAGE plpythonu IMMUTABLE AS $body$
  import numpy as np

  out = {
    1: [1,2,3,444],
    2: [2,2,3,3,3],
    3: [1,2,2,3,3,3],
  }
  return np.array(out[version]) # 444 is big enough to test endianness
$body$;

CREATE FUNCTION pg_temp.nd_as_intarray(
  i ndarray
) RETURNS int[]
TRANSFORM FOR TYPE ndarray
LANGUAGE plpythonu AS $body$
  import numpy as np

  return i.tolist()
$body$;

-- vi: expandtab sw=2 ts=2
