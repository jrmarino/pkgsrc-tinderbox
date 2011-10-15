# $NetBSD$
#

DISTNAME=	tinderbox-dragonfly-${TBOX_VERSION}
CATEGORIES=	pkgtools
MASTER_SITES=	http://tinderbox.marcuscom.com/
DISTFILES=	tinderbox-${TBOX_VERSION}.tar.gz

MAINTAINER=	draco@marino.st
HOMEPAGE=	http://tinderbox/marcuscom.com
COMMENT=	Tinderbox package building system (pkgsrc)
LICENSE=	modified-bsd

TBOX_VERSION=		3.4.r1
PKG_DESTDIR_SUPPORT=	user-destdir
ONLY_FOR_PLATFORM=	DragonFly-*-*

USE_TOOLS+=		perl
NO_BUILD=		yes
RCD_SCRIPTS=		tinderd

.include "options.mk"

post-extract:
.if empty(PKG_OPTIONS:Mwebui)
	${RM} -R ${WRKSRC}/webui
.endif

post-patch:
.if !empty(PKG_OPTIONS:Manybody)
	perl -i -pe 's/^if \[ `id -u` != 0 \]; then/if false; then/' \
		${WRKSRC}/tc
.endif
	cd ${WRKSRC} && ${FIND} -E . -regex '.*(orig|bak)' -exec ${RM} {} \;

do-install:
	${AUTO_MKDIRS} ${DESTDIR}${PREFIX}/tinderbox/scripts
	${INSTALL_MAN} ${WRKSRC}/man/man1/* \
	               ${DESTDIR}${PREFIX}/${PKGMANDIR}/man1
	${RM} -R ${WRKSRC}/man
	${INSTALL} ${WRKSRC}/etc/rc.d/tinderd \
		   ${DESTDIR}${PREFIX}/share/examples/rc.d
	${RM} -R ${WRKSRC}/etc/rc.d
	${INSTALL} ${WRKSRC}/* ${DESTDIR}${PREFIX}/tindexbox/scripts
	#${INSTALL} ${WRKSRC}/.version ${DESTDIR}${PREFIX}/tinderbox/scripts

.include "../../mk/bsd.pkg.mk"
