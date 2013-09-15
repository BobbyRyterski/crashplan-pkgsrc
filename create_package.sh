#!/usr/bin/bash

set -e

VERSION=3.5.3
TMPDIR=tmp
TARGETDIR=target
TARGET=$TARGETDIR/crashplan-${VERSION}.tgz
TARBALL=CrashPlan_${VERSION}_Solaris.tar.gz
URL=http://download.crashplan.com/installs/solaris/install/CrashPlan/${TARBALL}

mkdir -p $TMPDIR
mkdir -p $TARGETDIR

# output to tmpdir
pushd $TMPDIR > /dev/null
wget $URL
tar xzf $TARBALL 
popd > /dev/null
mkdir -p files
mv $TMPDIR/CrashPlan/root/opt/sfw/crashplan/ files

# forgotten dirs
mkdir -p files/crashplan/log
mkdir -p files/crashplan/upgrade/UpgradeUI

# fix permissions
chown -R root:staff files/crashplan
while read line
do
  set -- $line
  case "$2" in
  [def])
    chmod $5 files/${4:9}
    ;;
  esac
done < $TMPDIR/CrashPlan/pkgmap

(cd files; find * -type f -or -type l | sort) > packlist

pkg_create -B build-info -c comment -d description -f packlist -I /opt/local -i install -k deinstall -p files -P sun-jre6 -U $TARGET
