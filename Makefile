#
# Makefile
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

TOPDIR = $(shell pwd)
export TOPDIR

include Makefile.inc

test: all

install:
	for i in usr/libexec sbin $(mandir)/man8 etc/kernel/postinst.d \
			/etc/kernel/prerm.d ; do \
		if [ ! -d $(DESTDIR)/$$i ]; then \
			mkdir -p $(DESTDIR)/$$i; \
		fi; \
	done
	sed 's/%VERSIONTAG%/$(VERSION)/' < mkinitrd > $(DESTDIR)/sbin/mkinitrd
	chmod 755 $(DESTDIR)/sbin/mkinitrd
	install -m755 lsinitrd $(DESTDIR)/sbin/lsinitrd
	install -m755 mkliveinitrd $(DESTDIR)/usr/libexec/mkliveinitrd
	install -m755 mkmrstinitrd $(DESTDIR)/usr/libexec/mkmrstinitrd
	install -m644 mkinitrd.8 $(DESTDIR)/$(mandir)/man8/mkinitrd.8

test-archive:
	@rm -rf /tmp/mkinitrd-$(VERSION) /tmp/mkinitrd-$(VERSION)-tmp
	@mkdir -p /tmp/mkinitrd-$(VERSION)-tmp
	@git archive --format=tar $(shell git-branch | awk '/^*/ { print $$2 }') | ( cd /tmp/mkinitrd-$(VERSION)-tmp/ ; tar x )
	@git diff | ( cd /tmp/mkinitrd-$(VERSION)-tmp/ ; patch -s -p1 -b -z .gitdiff )
	@mv /tmp/mkinitrd-$(VERSION)-tmp/ /tmp/mkinitrd-$(VERSION)/
	@dir=$$PWD; cd /tmp; tar -c --bzip2 -f $$dir/mkinitrd-$(VERSION).tar.bz2 mkinitrd-$(VERSION)
	@rm -rf /tmp/mkinitrd-$(VERSION)
	@echo "The archive is in mkinitrd-$(VERSION).tar.bz2"

archive:
	git tag $(GITTAG) refs/heads/master
	@rm -rf /tmp/mkinitrd-$(VERSION) /tmp/mkinitrd-$(VERSION)-tmp
	@mkdir -p /tmp/mkinitrd-$(VERSION)-tmp
	@git archive --format=tar $(GITTAG) | ( cd /tmp/mkinitrd-$(VERSION)-tmp/ ; tar x )
	@mv /tmp/mkinitrd-$(VERSION)-tmp/ /tmp/mkinitrd-$(VERSION)/
	@dir=$$PWD; cd /tmp; tar -c --bzip2 -f $$dir/mkinitrd-$(VERSION).tar.bz2 mkinitrd-$(VERSION)
	@rm -rf /tmp/mkinitrd-$(VERSION)
	@echo "The archive is in mkinitrd-$(VERSION).tar.bz2"
