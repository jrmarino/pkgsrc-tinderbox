#!/bin/sh

SCRIPT=`/usr/bin/stat -f $0`
SCRIPTPATH=`/usr/bin/dirname ${SCRIPT}`
HEADDIR=`realpath ${SCRIPTPATH}/../..`
SCRIPTDIR=`realpath ${SCRIPTPATH}`
DFLYDIR=${HEADDIR}/DragonFly
PATCHDIR=${HEADDIR}/pkgsrc/pkgtools/tinderbox-dragonfly/patches

rm -f ${PATCHDIR}/*
cd ${DFLYDIR}

while read mapline; do
	patch_id=`echo $mapline | /usr/bin/sed "s/:.*//"`
	target=`echo $mapline | /usr/bin/sed "s/[^\w]*://"`
	/usr/pkg/bin/pkgdiff ../FreeBSD/${target} ${target} > ${PATCHDIR}/patch-${patch_id} 
done < ${SCRIPTDIR}/patch.map

echo "Don't forget to regenerate the distinfo"


