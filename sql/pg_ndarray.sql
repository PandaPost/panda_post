CREATE TYPE ndarray;

CREATE FUNCTION ndarray_in(cstring) RETURNS ndarray LANGUAGE INTERNAL IMMUTABLE STRICT AS 'byteain';
CREATE FUNCTION ndarray_out(ndarray) RETURNS cstring LANGUAGE INTERNAL IMMUTABLE STRICT AS 'byteaout';

CREATE TYPE ndarray(
    INPUT = ndarray_in
    , OUTPUT = ndarray_out
    , LIKE = pg_catalog.bytea
);

CREATE FUNCTION ndarray_to_plpython(internal) RETURNS internal LANGUAGE c
    AS '$libdir/pg_ndarray', 'PLyNdarray_FromDatum';
CREATE FUNCTION ndarray_from_plpython(internal) RETURNS internal LANGUAGE c
    AS '$libdir/pg_ndarray', 'PLyObject_To_ndarray';

CREATE TRANSFORM FOR ndarray LANGUAGE plpythonu(
    FROM SQL WITH FUNCTION ndarray_to_plpython(internal)
    , TO SQL WITH FUNCTION ndarray_from_plpython(internal)
);
