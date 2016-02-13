-- You will need to delete this if you do not want to use pgTap!
CREATE SCHEMA IF NOT EXISTS tap;
CREATE EXTENSION IF NOT EXISTS pgtap SCHEMA tap;

-- Add any test dependency statements here
CREATE EXTENSION IF NOT EXISTS plpythonu;
CREATE EXTENSION IF NOT EXISTS lambda;
CREATE EXTENSION PandaPost;

-- General test infrastructure (should maybe be in it's own file)
CREATE FUNCTION pg_temp.test_value(
) RETURNS ndarray
TRANSFORM FOR TYPE ndarray
LANGUAGE plpythonu IMMUTABLE AS $body$
  import numpy as np

  return np.array([1,2,3,444]) # 444 is big enough to test endianness
$body$;
