EXTENSION = PandaPost

include pgxntool/base.mk

# Tests require the lambda extension
.PHONY: lambda
lambda: $(DESTDIR)$(datadir)/extension/lambda.control

$(DESTDIR)$(datadir)/extension/lambda.control:
	pgxn --verbose install lambda
testdeps: lambda

define get_numpy_include
from numpy.lib.utils import get_include
print get_include()
endef

ifeq ($(PYTHON),)
$(error PYTHON is not set)
endif

python_version = $(shell ${PYTHON} --version 2>&1 | cut -d ' ' -f 2 | cut -d '.' -f 1-2)
PYTHON_CONFIG ?= python${python_version}-config

PY_LIBSPEC = $(shell ${PYTHON_CONFIG} --libs)
PY_INCLUDESPEC = $(shell ${PYTHON_CONFIG} --includes)
PY_CFLAGS = $(shell ${PYTHON_CONFIG} --cflags)
PY_LDFLAGS = $(shell ${PYTHON_CONFIG} --ldflags)
LDFLAGS := $(PY_LDFLAGS) $(PY_ADDITIONAL_LIBS) $(filter -lintl,$(LIBS)) $(LDFLAGS)
override PG_CPPFLAGS  := $(PY_INCLUDESPEC) $(PG_CPPFLAGS)
override CPPFLAGS := $(PG_CPPFLAGS) $(CPPFLAGS)

#numpy_include ?= $(shell $(PYTHON) -c '$(get_numpy_include)')
#ifeq ($(numpy_include),)
#$(error could not determine numpy include path)
#endif

#override CPPFLAGS := $(python_includespec) -I$(numpy_include) $(CPPFLAGS)
#LDFLAGS += -L/opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/config -lpython2.7 -ldl -framework CoreFoundation
#LDFLAGS += -L/Users/decibel/pgsql/HEAD/src/pl/plpython/ -L/opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/config -lpython2.7 -ldl -framework CoreFoundation
#override CPPFLAGS += -I/Users/decibel/pgsql/HEAD/src/pl/plpython/
#override LDFLAGS += -L/Users/decibel/pgsql/HEAD/src/pl/plpython/
# vi: noexpandtab
