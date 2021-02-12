#
# Makefile.inc
#
# Copyright 2007-2008 Red Hat, Inc.  All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

GITTAG = $(VERSION)-$(RELEASE)
CVSROOT = $(shell cat CVS/Root)

VERSION = $(shell awk -F= '/^VERSION=/ { print $$2 }' $(TOPDIR)/mkinitrd)
export VERSION
RELEASE = 1
export RELEASE

LIB ?= lib
export LIB

ARCH := $(patsubst i%86,i386,$(shell uname -m))
ARCH := $(patsubst sparc%,sparc,$(ARCH))
ARCH := $(patsubst ppc%,ppc,$(ARCH))

CC = gcc
CFLAGS ?= -Wall -Werror -g -D_FORTIFY_SOURCE=2 -Wno-unused-function -fPIC \
	  -std=gnu99 -D_GNU_SOURCE=1

mandir = usr/share/man

all:: $(TARGETS) subdirs

$(shell pwd)/version.h: $(TOPDIR)/mkinitrd $(TOPDIR)/Makefile.inc \
		$(TOPDIR)/Makefile $(shell pwd)/Makefile
	@echo making $(shell pwd)/version.h
	@echo '#ifdef VERSION' > version.h
	@echo '#undef VERSION' >> version.h
	@echo '#endif' >> version.h
	@echo '#define VERSION' \"$(VERSION)\" >> version.h

.PHONY:: subdirs $(SUBDIRS) staticlibs clean all
subdirs :: $(shell pwd)/version.h
subdirs ::
	@if [ -n "$(SUBDIRS)" ]; then \
	for n in $(SUBDIRS) ; do make -C $$n staticlibs || exit 1 ; done ; \
	for n in $(SUBDIRS) ; do make -C $$n all || exit 1 ; done ; \
	fi

staticlibs :: $(shell pwd)/version.h $(LIBS)

$(OBJECTS): %.o : %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean::
	rm -f $(TARGETS) *.o *.a version.h
	@for n in $(SUBDIRS); do make -C $$n clean ; done
