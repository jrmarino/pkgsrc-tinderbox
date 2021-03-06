# Copyright (c) 2008 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# $MCom: portstools/tinderbox/lib/db-mysql.sh,v 1.3.2.3 2010/01/02 20:04:29 marcus Exp $
#
export DB_MAN_PREREQS="p5-DBD-mysql mysql-client"
export DB_OPT_PREREQS="php5*-mysql"

if [ -n "${db_admin_pass}" ]; then
    export DB_PROMPT='true'
    export db_admin_pass
    export DB_SCHEMA_LOAD='/usr/pkg/bin/mysql -u${db_admin} --password="${db_admin_pass}" -h ${db_host} ${db_name} < "${schema_file}"'
    export DB_DUMP='/usr/pkg/bin/mysqldump --no-create-info --skip-opt -u${db_admin} --password="${db_admin_pass}" -h ${db_host} ${db_name} %%TABLE%% >> ${tmpfile}'
    export DB_DROP='/usr/pkg/bin/mysqladmin -u${db_admin} --password=${db_admin_pass} -h ${db_host} drop ${db_name}'
    export DB_CHECK='/usr/pkg/bin/mysql -u${db_admin} -B -s --password="${db_admin_pass}" -h ${db_host} -e "SELECT 0" ${db_name}'
    export DB_CREATE='/usr/pkg/bin/mysqladmin -u${db_admin} --password="${db_admin_pass}" -h ${db_host} create ${db_name}'
    export DB_GRANT='/usr/pkg/bin/mysql -u${db_admin} --password="${db_admin_pass}" -h ${db_host} -e "GRANT SELECT, INSERT, UPDATE, DELETE ON ${db_name}.* TO '"'"'${db_user}'"'"'@'"'"'${grant_host}'"'"' IDENTIFIED BY '"'"'${db_pass}'"'"' ; FLUSH PRIVILEGES" mysql'
    export DB_QUERY='/usr/pkg/bin/mysql --batch --skip-column-names -u${db_admin} --password="${db_admin_pass}" -h ${db_host} -e "${query}" ${db_name}'
    export DB_USER_PROMPT='true'
    export DB_CREATE_USER='true'
else
    export DB_PROMPT='echo "The next prompt will be for ${db_admin}'"'"'s password to the ${db_name} database." | /usr/bin/fmt 75 79'
    export DB_SCHEMA_LOAD='/usr/pkg/bin/mysql -u${db_admin} -p -h ${db_host} ${db_name} < "${schema_file}"'
    export DB_DUMP='/usr/pkg/bin/mysqldump --no-create-info --skip-opt -u${db_admin} -p -h ${db_host} ${db_name} %%TABLE%% >> ${tmpfile}'
    export DB_DROP='/usr/pkg/bin/mysqladmin -u${db_admin} -p -h ${db_host} drop ${db_name}'
    export DB_CHECK='/usr/pkg/bin/mysql -u${db_admin} -B -s -p -h ${db_host} -e "SELECT 0" ${db_name}'
    export DB_CREATE='/usr/pkg/bin/mysqladmin -u${db_admin} -p -h ${db_host} create ${db_name}'
    export DB_GRANT='/usr/pkg/bin/mysql -u${db_admin} -p -h ${db_host} -e "GRANT SELECT, INSERT, UPDATE, DELETE ON ${db_name}.* TO '"'"'${db_user}'"'"'@'"'"'${grant_host}'"'"' IDENTIFIED BY '"'"'${db_pass}'"'"' ; FLUSH PRIVILEGES" mysql'
    export DB_QUERY='/usr/pkg/bin/mysql --batch --skip-column-names -u${db_admin} -p -h ${db_host} -e "${query}" ${db_name}'
    export DB_USER_PROMPT='true'
    export DB_CREATE_USER='true'
fi
