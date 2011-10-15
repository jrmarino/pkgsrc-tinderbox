INSERT INTO config VALUES ('LOG_DIRECTORY', '');
INSERT INTO config VALUES ('LOG_DOCOPY', '0');
UPDATE ports SET port_maintainer=REPLACE(port_maintainer, '@FreeBSD.org','@freebsd.org');
UPDATE config SET config_option_value = '3.2.1' WHERE config_option_name = '__DSVERSION__';
