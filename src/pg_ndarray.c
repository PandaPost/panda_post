/*
 * pg_ndarray.c:
 * 		Python / NumPy ndarray data type for Postgres
 *
 * Copyright (c) 2016 Jim Nasby, Blue Treble Consulting http://BlueTreble.com
 */

#include "postgres.h"
#include "fmgr.h"

#include "plpython.h"

static PyObject *
PLyNdarray_FromDatum(Datum d)
{
    text	   *txt = DatumGetByteaP(d);
	char	   *str = VARDATA(txt);
	size_t		size = VARSIZE(txt) - VARHDRSZ;
    uint8_t     version;
    static PyObject *unpickle;
    PyObject   *pyvalue;

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
            pyvalue = PyObject_CallFunction(unpickle, "s", PyBytes_FromStringAndSize(str, size) );
            if (!pyvalue)
                elog(ERROR, "unpickling failed");
            break;
        default:
            elog(ERROR, "unsupported ndarray storage version %u", version);
    }

    return pyvalue;
}

/*
 * Convert a numpy array to a bytea by pickling
 */
static Datum
PLyObject_To_ndarray(PyObject *plrv)
{
	PyObject   *volatile plrv_so = NULL;
    static PyObject *pickle;
    PyObject   *pyvalue;

	Datum		rv;

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


	Assert(plrv != Py_None);

    pyvalue = PyObject_CallFunction(pickle, "O", plrv);

    if (!pyvalue)
		elog(ERROR, "could not pickle Python object");

	plrv_so = PyObject_Bytes(plrv);
	if (!plrv_so)
		elog(ERROR, "could not create bytes representation of Python object");

	PG_TRY();
	{
		char	   *plrv_sc = PyBytes_AsString(plrv_so);
		size_t		len = PyBytes_Size(plrv_so);
		size_t		size = len + VARHDRSZ +1;
		bytea	   *result = palloc(size);

		SET_VARSIZE(result, size);

        /* Store version number in first byte */
        *VARDATA(result) = (uint8_t) 1;

		memcpy(VARDATA(result) + 1, plrv_sc, len);
		rv = PointerGetDatum(result);
	}
	PG_CATCH();
	{
		Py_XDECREF(plrv_so);
		PG_RE_THROW();
	}
	PG_END_TRY();

	Py_XDECREF(plrv_so);

	return rv;
}

/* vi: expandtab ts=2 sw=2 */
