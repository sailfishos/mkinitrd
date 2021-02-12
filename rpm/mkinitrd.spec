Summary: Creates an initial ramdisk image for preloading modules
Name: mkinitrd
Version: 7.0.17
Release: 2
License: GPLv2+
Group: System/Base
Source0: mkinitrd-%{version}.tar.bz2
Patch0:  fix-a-weird-btrfs-root-issue.patch
Patch1:  timeout-fix.patch
Patch2:  mkmrstinitrd.patch 
Patch3:  mkinitrd-lsb-functions-optional.patch
Patch4:  systemd_mkinitrd_live_mrst.patch
Patch5:  modprobe_conf.patch
Patch6:  mount-run-and-create-dirs-for-udev.patch
Patch7:  0001-Fix-for-systemd-187.patch
Requires: /bin/sh, /sbin/losetup
Requires: fileutils,  mktemp >= 1.5-5
Requires: /bin/tar
Requires: /bin/find
Requires: /bin/grep
Requires: /bin/gzip
Requires: /bin/cpio
Requires: filesystem >= 2.1.0
Requires: e2fsprogs >= 1.38-12,   coreutils
Requires: elfutils-libelf
Requires: device-mapper
Requires: util-linux
Requires: grubby
Requires: psmisc
# New paths and files in kmod replaced module-init-tools
Requires: kmod >= 9
# udevadm etc are in this.
Requires: systemd >= 187
# awk is required by /usr/libexec/mkliveinitrd
Requires: /usr/bin/awk

%description
mkinitrd creates filesystem images for use as initial ram filesystem
(initramfs) images.  These images are used to find and mount the root
filesystem.

%prep
%setup -q 
%patch0 -p1
%patch1 -p1
%patch2 -p1
%patch3 -p1
%patch4 -p1
%patch5 -p1
%patch6 -p1
%patch7 -p1

#
# 2x30 seconds is waay too long a timeout to wait for udev
#
find . -name "Makefile*" -exec sed -i 's|-Werror||g' {} \;

%build
make LIB=%{_lib}

%install
rm -rf $RPM_BUILD_ROOT
make LIB=%{_lib} DESTDIR=$RPM_BUILD_ROOT mandir=%{_mandir} install

%files
%defattr(-,root,root,-)
%attr(755,root,root) /sbin/mkinitrd
%attr(644,root,root) %{_mandir}/man8/mkinitrd.8*
%attr(755,root,root) /usr/libexec/mkliveinitrd
%attr(755,root,root) /usr/libexec/mkmrstinitrd
%attr(755,root,root) /sbin/lsinitrd

