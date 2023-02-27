#!/bin/sh
if [ ! -d $source_configs_path ]; then
	echo -e `date "+%Y-%m-%d %H:%M:%S" `"[$FUNCNAME] "" desination path of source_config doesn't exist..."
	mkdir -p $source_configs_path
fi 