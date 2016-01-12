CREATE FUNCTION ndarray_to_plpython(internal) RETURNS internal LANGUAGE c
    AS '$libdir/pg_ndarray', 'PLyNdarray_FromDatum';
CREATE FUNCTION ndarray_from_plpython(internal) RETURNS internal LANGUAGE c
    AS '$libdir/pg_ndarray', 'PLyObject_To_ndarray';
