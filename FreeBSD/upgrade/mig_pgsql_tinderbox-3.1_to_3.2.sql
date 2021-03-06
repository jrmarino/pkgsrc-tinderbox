IF NOT EXISTS(SELECT tablename FROM pg_catalog.pg_tables WHERE tablename = 'logfile_patterns') THEN
CREATE TABLE logfile_patterns (
	logfile_pattern_id INTEGER PRIMARY KEY,
	logfile_pattern_tag VARCHAR(30) NOT NULL,
	logfile_pattern_severity VARCHAR(12) CHECK (logfile_pattern_severity IN ('error','warning','information')) DEFAULT 'information',
	logfile_pattern_expr TEXT,
	logfile_pattern_color VARCHAR(20) NOT NULL
);
END IF
DELETE FROM logfile_patterns WHERE logfile_pattern_id % 10 = 0;
INSERT INTO logfile_patterns VALUES ( 10, 'File not found', 'error', '/^(?!fetch).*No such file or directory/', 'Red' );
INSERT INTO logfile_patterns VALUES ( 500, 'Declaration prototype', 'warning', '/warning: function declaration isn\'t a prototype/', 'Violet' );
INSERT INTO logfile_patterns VALUES ( 510, 'No prototype', 'warning', '/warning: no previous prototype for \'.*\'/', 'Violet' );
INSERT INTO logfile_patterns VALUES ( 520, 'Implicit function', 'warning', '/warning: implicit declaration of function \'.*\'/', 'Magenta' );
INSERT INTO logfile_patterns VALUES ( 530, 'Nested declaration', 'warning', '/warning: nested extern declaration of \'.*\'/', 'Magenta' );
INSERT INTO logfile_patterns VALUES ( 540, 'ISO C90', 'warning', '/warning: ISO C90 does not support \'.*\'|warning: C.. style comments are not allowed in ISO C90|warning: ISO C90 forbids mixed declarations and code/', 'Orange' );
INSERT INTO logfile_patterns VALUES ( 550, 'ISO C', 'warning', '/warning: ISO C doesn\'t support unnamed structs/', 'Orange' );
INSERT INTO logfile_patterns VALUES ( 560, 'GCC', 'warning', '/warning: type of bit-field \'.*\' is a GCC extension/', 'Orange' );
INSERT INTO logfile_patterns VALUES ( 570, 'Pointer target type', 'warning', '/warning: passing argument . of \'.*\' discards qualifiers from pointer target type|warning: assignment discards qualifiers from pointer target type/', 'OrangeRed' );
INSERT INTO logfile_patterns VALUES ( 580, 'Pointer signedness', 'warning', '/warning: pointer targets in passing argument . of \'.*\' differ in signedness/', 'OrangeRed' );
INSERT INTO logfile_patterns VALUES ( 590, 'Incompatible pointer', 'warning', '/warning: passing argument . of \'.*\' from incompatible pointer type/', 'OrangeRed' );
INSERT INTO logfile_patterns VALUES ( 600, 'Expected format', 'warning', '/warning: format \'.*\' expects type \'.*\', but argument . has type \'.*\'/', 'OrangeRed' );
INSERT INTO logfile_patterns VALUES ( 610, 'Conversion', 'warning', '/warning: deprecated conversion from .* to .*/', 'OrangeRed' );
INSERT INTO logfile_patterns VALUES ( 620, 'Signed comparison', 'warning', '/warning: comparison between signed and unsigned/', 'OrangeRed' );
INSERT INTO logfile_patterns VALUES ( 630, 'Comp. always false', 'warning', '/warning: comparison is always false due to limited range of data type/', 'OrangeRed' );
INSERT INTO logfile_patterns VALUES ( 640, 'Different size cast', 'warning', '/warning: cast from pointer to integer of different size/', 'OrangeRed' );
INSERT INTO logfile_patterns VALUES ( 1000, 'Unused param/var', 'information', '/warning: unused variable \'.*\'|warning: unused parameter \'.*\'/', 'Blue' );
INSERT INTO logfile_patterns VALUES ( 1010, 'Definition not used/defined', 'information', '/warning: \'.*\' defined but not used|warning: .* is not defined/', 'Blue' );
INSERT INTO logfile_patterns VALUES ( 1020, 'Enum', 'information', '/warning: enumeration value \'.*\' not handled in switch|warning: comma at end of enumerator list/', 'Blue' );
INSERT INTO logfile_patterns VALUES ( 1030, 'Warn_unused_result', 'information', '/warning: ignoring return value of .*, declared with attribute warn_unused_result/', 'Blue' );
INSERT INTO logfile_patterns VALUES ( 1040, 'Declaration', 'information', '/warning: declaration does not declare anything/', 'Blue' );
INSERT INTO logfile_patterns VALUES ( 1050, 'Semicolon', 'information', '/warning: extra semicolon in struct or union specified/', 'Blue' );
UPDATE config SET config_option_value = '3.2' WHERE config_option_name = '__DSVERSION__';
