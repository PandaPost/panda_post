CREATE TYPE ndarray;

SET client_min_messages = WARNING;
CREATE FUNCTION ndarray_in(cstring) RETURNS ndarray LANGUAGE INTERNAL IMMUTABLE STRICT AS 'byteain';
CREATE FUNCTION ndarray_out(ndarray) RETURNS cstring LANGUAGE INTERNAL IMMUTABLE STRICT AS 'byteaout';
SET client_min_messages = NOTICE;

CREATE TYPE ndarray(
  INPUT = ndarray_in
  , OUTPUT = ndarray_out
  , LIKE = pg_catalog.bytea
);

/*
 * Stable in case we create a new storage version and the function dynamically
 * updates to it.
 */
CREATE FUNCTION ndarray_to_plpython(internal) RETURNS internal LANGUAGE c STABLE STRICT
  AS '$libdir/PandaPost', 'PLyNdarray_FromDatum';
CREATE FUNCTION ndarray_from_plpython(internal) RETURNS ndarray LANGUAGE c STABLE STRICT
  AS '$libdir/PandaPost', 'PLyObject_To_ndarray';

CREATE TRANSFORM FOR ndarray LANGUAGE plpythonu(
  FROM SQL WITH FUNCTION ndarray_to_plpython(internal)
  , TO SQL WITH FUNCTION ndarray_from_plpython(internal)
);

CREATE FUNCTION repr(
  i ndarray
) RETURNS text LANGUAGE sql STRICT IMMUTABLE
AS $body$
import numpy

return repr(i)
$body$;

