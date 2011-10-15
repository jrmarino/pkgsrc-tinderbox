UPDATE hooks SET hook_description='Hook to run prior to updating a Jail.\nIf this hook returns a non-zero value, the Jail will not be updated.\nThe following environment will be passed to the hook command:\n\tJAIL : Jail name\n\tUPDATE_CMD : Update command\n\tPB : Tinderbox root\n\tJAIL_ARCH : Jail architecture target' WHERE hook_name='preJailUpdate';
UPDATE config SET config_option_value = '3.2.3' WHERE config_option_name = '__DS
VERSION__';
