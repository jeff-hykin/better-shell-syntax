groupadd -r myma && useradd --no-log-init -r -g myma myma \
	&& [[ -v "${TYPEORM_SYNCHRONIZE}" ]] ./node_modules/.bin/typeorm schema:sync