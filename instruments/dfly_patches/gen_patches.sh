#!/bin/sh

PKGSRC=pkgsrc/pkgtools/tinderbox-dragonfly
SCRIPT=`/usr/bin/stat -f $0`
SCRIPTPATH=`/usr/bin/dirname ${SCRIPT}`
HEADDIR=`realpath ${SCRIPTPATH}/../..`
SCRIPTDIR=`realpath ${SCRIPTPATH}`
DFLYDIR=${HEADDIR}/DragonFly
PATCHDIR=${HEADDIR}/${PKGSRC}/patches
REALPKGLOC=/usr/${PKGSRC}

rm -f ${PATCHDIR}/*
cd ${DFLYDIR}

while read mapline; do
	patch_id=`echo $mapline | /usr/bin/sed "s/:.*//"`
	target=`echo $mapline | /usr/bin/sed "s/[^\w]*://"`
	if [ -f ${target} ]; then
	   /usr/pkg/bin/pkgdiff ../FreeBSD/${target} ${target} > ${PATCHDIR}/patch-${patch_id}
	fi
done < ${SCRIPTDIR}/patch.map

rm -f ${REALPKGLOC}/patches/*
cp ${PATCHDIR}/* ${REALPKGLOC}/patches
cd ${REALPKGLOC}
/usr/pkg/bin/bmake distinfo
cp ${REALPKGLOC}/distinfo ${HEADDIR}/${PKGSRC}


