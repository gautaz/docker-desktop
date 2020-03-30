#!/usr/bin/env sh

case "${OSTYPE}" in
	darwin*)
		echo "Using Darwin settings"
		USERID=0
		GROUPID=0
		;;
	*)
		echo "Using common settings"
		USERID="$(id -u)"
		GROUPID="$(id -g)"
		;;
esac

cat > .env <<- EOE
	USERID=${USERID}
	GROUPID=${GROUPID}
	USERLOGIN=${LOGNAME}
EOE

DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 docker-compose build