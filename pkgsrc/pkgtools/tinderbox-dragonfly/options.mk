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
PKG_FAIL_REASON+=	Tinderbox requires a database or confirmation you have already installed on.
PKG_FAIL_REASON+=	Please select one of need-pgsql, have-pgsql, need-mysql, have-pgsql
.endif

.if !empty(PKG_OPTIONS:need-pgsql)
.include "../../mk/pgsql.buildlink3.mk"
.endif

.if !empty(PKG_OPTIONS:Mneed-mysql)
.include "../../mk/mysql.buildlink3.mk"
.endif

.if !empty(PKG_OPTIONS:need-pgsql) || !empty(PKG_OPTIONS:have-pgsql)
RUN_DEPENDS+=	DBD-Pg>=2.12:../../database/p5-DBD-postgresql
.if !empty(webui)
RUN_DEPENDS+=	MDB2_Driver_pgsql>1.5:../../database/pear-MDB2_Driver_pgsql
RUN_DEPENDS+=	php-pgsql>=5.1:../../databases/php-pgsql
.endif
.endif

.if !empty(PKG_OPTIONS:need-mysql) || !empty(PKG_OPTIONS:have-mysql)
RUN_DEPENDS+=	DBD-mysql>=4:../../database/pg-DBD-mysql
.if !empty(webui)
RUN_DEPENDS+=	MDB2_Driver_mysql>1.5:../../database/pear-MDB2_Driver_mysql
RUN_DEPENDS+=	php-mysql>=5.1:../../databases/php-mysql
.endif
.endif

.if !empty(webui)
PLIST.WEBUI=	yes
.endif

#####################
#  LIST OPEN FILES  #
#####################

.if !empty(lsof)
RUN_DEPENDS+=	lsof>=4.83:../../sysutils/lsof
.endif
