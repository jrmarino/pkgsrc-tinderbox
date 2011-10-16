# $NetBSD$

PKG_OPTIONS_VAR=	PKG_OPTIONS.tbox-dfly
PKG_SUPPORTED_OPTIONS=	need-pgsql have-pgsql need-mysql have-mysql webui anybody lsof
PKG_SUGGESTED_OPTIONS=	need-pgsql webui lsof
PLIST_VARS+=		WEBUI

.include "../../mk/bsd.options.mk"

########################################
#  WEB INTERFACE AND DATABASE OPTIONS  #
########################################

.if  empty(PKG_OPTIONS:Mneed-pgsql) \
  && empty(PKG_OPTIONS:Mhave-pgsql) \
  && empty(PKG_OPTIONS:Mneed-mysql) \
  && empty(PKG_OPTIONS:Mhave-mysql)
PKG_FAIL_REASON+=	"Tinderbox requires a database or confirmation you have already installed on."
PKG_FAIL_REASON+=	"Please select one of need-pgsql, have-pgsql, need-mysql, have-pgsql"
.endif

.if !empty(PKG_OPTIONS:Mneed-pgsql)
.include "../../mk/pgsql.buildlink3.mk"
.endif

.if !empty(PKG_OPTIONS:Mneed-mysql)
.include "../../mk/mysql.buildlink3.mk"
.endif

.if !empty(PKG_OPTIONS:Mwebui)
PLIST.WEBUI=	yes
.include "../../lang/php/phpversion.mk"
.endif

.if !empty(PKG_OPTIONS:Mneed-pgsql) || !empty(PKG_OPTIONS:Mhave-pgsql)
DEPENDS+=	p5-DBD-postgresql>=2.12:../../databases/p5-DBD-postgresql
.if !empty(PKG_OPTIONS:Mwebui)
DEPENDS+=	${PHP_PKG_PREFIX}-pear-MDB2_Driver_pgsql:../../databases/pear-MDB2_Driver_pgsql
DEPENDS+=	${PHP_PKG_PREFIX}-pgsql>=5.1:../../databases/php-pgsql
.endif
.endif

.if !empty(PKG_OPTIONS:Mneed-mysql) || !empty(PKG_OPTIONS:Mhave-mysql)
DEPENDS+=	p5-DBD-mysql>=4:../../databases/p5-DBD-mysql
.if !empty(PKG_OPTIONS:Mwebui)
DEPENDS+=	${PHP_PKG_PREFIX}-perar-MDB2_Driver_mysql>1.5:../../databases/pear-MDB2_Driver_mysql
DEPENDS+=	${PHP_PKG_PREFIX}-mysql>=5.1:../../databases/php-mysql
.endif
.endif

#####################
#  LIST OPEN FILES  #
#####################

.if !empty(PKG_OPTIONS.Mlsof)
DEPENDS+=	lsof>=4.83:../../sysutils/lsof
.endif
