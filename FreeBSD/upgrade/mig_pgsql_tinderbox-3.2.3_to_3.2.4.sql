CREATE TABLE build_groups(
	build_group_name VARCHAR(30) NOT NULL,
	build_id INTEGER REFERENCES builds(build_id) ON UPDATE CASCADE,
	PRIMARY KEY (build_group_name, build_id)
);
UPDATE config SET config_option_value = '3.2.4' WHERE config_option_name = '__DSVERSION__';
