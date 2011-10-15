ALTER TABLE user_permissions DROP PRIMARY KEY;
ALTER TABLE user_permissions ADD PRIMARY KEY (user_id, user_permission_object_type, user_permission_object_id, user_permission);
INSERT INTO config VALUES ('TINDERD_LOGFILE', '/dev/null');
UPDATE config SET config_option_value = '3.1' WHERE config_option_name = '__DSVERSION__';
