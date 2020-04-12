#!/usr/bin/env sh
set -e

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

if [ ! -e .env ]; then
	ORIGINAL_STTY="$(stty -g)"
	stty -echo
	cat > .env <<- EOE
		USERID=${USERID}
		GROUPID=${GROUPID}
		USERLOGIN=${LOGNAME}
		PASSWORD=$(mkpasswd --method=SHA-512 --stdin)
		TIMEZONE=${TZ:-$(wget -O - -q http://geoip.ubuntu.com/lookup | sed 's#.*<TimeZone>\(.*\)</TimeZone>.*#\1#')}
		I3THEME=${I3THEME:-default-light}
	EOE
	stty "${ORIGINAL_STTY}"
	echo
fi

DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 docker-compose build
