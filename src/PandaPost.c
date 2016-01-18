/*
 * pg_ndarray.c:
 *     Python / NumPy ndarray data type for Postgres
 *
 * Copyright (c) 2016 Jim Nasby, Blue Treble Consulting http://BlueTreble.com
 */

#include "postgres.h"
#include "fmgr.h"

#include "plpython.h"

#include "plpy_typeio.h"

// #include "numpy/ndarrayobject.h"

PG_MODULE_MAGIC;


PG_FUNCTION_INFO_V1(PLyNdarray_FromDatum);
Datum
PLyNdarray_FromDatum(PG_FUNCTION_ARGS)
{
  text     *txt = PG_GETARG_BYTEA_P(0);
  char     *str = VARDATA(txt);
  size_t    size = VARSIZE(txt) - VARHDRSZ;
  uint8_t     version;
  static PyObject *unpickle;
  PyObject   *pyvalue;
  PyObject *b;

  /* First byte is a verision number */
  version = *str;
  str++;
  size--;

  /* Try to import cPickle.  If it doesn't exist, fall back to pickle. */
  if (!unpickle)
  {
    PyObject   *pickle_module;

    pickle_module = PyImport_ImportModule("cPickle");
    if (!pickle_module)
    {
      PyErr_Clear();
      pickle_module = PyImport_ImportModule("pickle");
    }
    if (!pickle_module)
      elog(ERROR, "could not import a module for unpickling");

    unpickle = PyObject_GetAttrString(pickle_module, "loads");
    // This can probably go away
    if (!unpickle)
      elog(ERROR, "no loads attribute in module");
  }

  switch (version)
  {
    case 1:
      /*
       * TODO: Avoid copying the string 2x 
       * http://stackoverflow.com/questions/25067790/create-pystring-from-c-character-array-without-copying
       */
      b = PyBytes_FromStringAndSize(str, size);
      pyvalue = PyObject_CallFunction(unpickle, "s", PyBytes_AsString(b));
      break;
    default:
      elog(ERROR, "unsupported ndarray storage version %u", version);
  }

	return PointerGetDatum(pyvalue);
}

/*
 * Convert a numpy array to a bytea by pickling
 */
PG_FUNCTION_INFO_V1(PLyObject_To_ndarray);
Datum
PLyObject_To_ndarray(PG_FUNCTION_ARGS)
{
  static PyObject *pickle = NULL;
  PyObject   *volatile pyndarray = (PyObject *) PG_GETARG_POINTER(0);
  PyObject   *pyvalue = NULL;
  Datum       rv;

  /*
  if (!PyArray_Check(pyndarray))
    ereport(ERROR,
      (errcode(ERRCODE_WRONG_OBJECT_TYPE),
       errmsg("not a Python numpy.ndarray")));
       */

    /* Try to import cPickle.  If it doesn't exist, fall back to pickle. */
    if (!pickle)
    {
      PyObject   *pickle_module;

      pickle_module = PyImport_ImportModule("cPickle");
      if (!pickle_module)
      {
        PyErr_Clear();
        pickle_module = PyImport_ImportModule("pickle");
      }
      if (!pickle_module)
        elog(ERROR, "could not import a module for unpickling");

      pickle = PyObject_GetAttrString(pickle_module, "dumps");
      if (!pickle)
        elog(ERROR, "no dumps attribute in module");
    }


    pyvalue = PyObject_CallFunction(pickle, "O", pyndarray);

    if (!pyvalue)
    elog(ERROR, "could not pickle Python object");

  PG_TRY();
  {
    char     *plrv_sc = PyBytes_AsString(pyvalue);
    size_t    len = PyBytes_Size(pyvalue);
    size_t    size = len + VARHDRSZ + 1;
    bytea     *result = palloc(size);

    SET_VARSIZE(result, size);

    /* Store version number in first byte */
    *VARDATA(result) = (uint8_t) 1;

    memcpy(VARDATA(result) + 1, plrv_sc, len);
    rv = PointerGetDatum(result);
  }
  PG_CATCH();
  {
    Py_XDECREF(pyvalue);
    PG_RE_THROW();
  }
  PG_END_TRY();

  Py_XDECREF(pyvalue);

  return rv;
}

/* vi: expandtab ts=2 sw=2 */
