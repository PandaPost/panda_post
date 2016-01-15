EXTENSION = PandaPost

include pgxntool/base.mk

define get_numpy_include
from numpy.lib.utils import get_include
print get_include()
endef

ifeq ($(PYTHON),)
$(error PYTHON is not set)
endif

numpy_include := $(shell $(PYTHON) -c '$(get_numpy_include)')
ifeq ($(numpy_include),)
$(error could not determine numpy include path)
endif

override CPPFLAGS := $(python_includespec) -I$(numpy_include) $(CPPFLAGS)
LDFLAGS += -L/opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/config -lpython2.7 -ldl -framework CoreFoundation

# vi: noexpandtab
