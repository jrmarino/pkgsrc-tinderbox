ALTER TABLE port_dependencies MODIFY dependency_type VARCHAR(16) CHECK (dependency_type IN ('UNKNOWN', 'EXTRACT_DEPENDS', 'PATCH_DEPENDS', 'FETCH_DEPENDS', 'BUILD_DEPENDS', 'LIB_DEPENDS', 'RUN_DEPENDS', 'TEST_DEPENDS')) DEFAULT 'UNKNOWN';
UPDATE logfile_patterns SET logfile_pattern_expr = '/^(?!fetch).*No such file or directory/' WHERE logfile_pattern_id = '10';
UPDATE config SET config_option_value = '3.3' WHERE config_option_name = '__DSVERSION__';
