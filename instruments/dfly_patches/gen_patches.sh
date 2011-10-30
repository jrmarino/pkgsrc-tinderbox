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
	target=`echo $mapline | /usr/bin/sed "s/^.*://"`
	if [ -f ${target} ]; then
	   freebsd_target=../FreeBSD/${target}
	   if [ ! -f ${freebsd_target} ]; then
	      /usr/pkg/bin/pkgdiff /dev/null ${target} | \
	        sed 's/^--- \/dev\/null[^I].*/--- \/dev\/null/' > ${PATCHDIR}/patch-${patch_id}
	   else
	      /usr/pkg/bin/pkgdiff ${freebsd_target} ${target} > ${PATCHDIR}/patch-${patch_id}
	   fi
	   DOUBLECHK=`head ${PATCHDIR}/patch-${patch_id}`
	   if [ "${DOUBLECHK}" = "" ]; then
	   	echo "patch-${patch_id} is empty, so remove DragonFly/${target}"; \
	   	rm ${PATCHDIR}/patch-${patch_id};
	   fi
	fi
done < ${SCRIPTDIR}/patch.map

rm -f ${REALPKGLOC}/patches/*
cp ${PATCHDIR}/* ${REALPKGLOC}/patches
cd ${REALPKGLOC}
/usr/pkg/bin/bmake distinfo
cp ${REALPKGLOC}/distinfo ${HEADDIR}/${PKGSRC}
