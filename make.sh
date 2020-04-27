#!/usr/bin/env sh
set -e

getGroupID() {
	echo "$(getent group $1 | cut -d: -f3)"
}

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
		AUDIOID="$(getGroupID audio)"
		VIDEOID="$(getGroupID video)"
		DOCKERID="$(getGroupID docker)"
		;;
esac

if [ ! -e .env ]; then
	ORIGINAL_STTY="$(stty -g)"
	stty -echo
	cat > .env <<- EOE
		USERID=${USERID}
		GROUPID=${GROUPID}
		AUDIOID=${AUDIOID}
		VIDEOID=${VIDEOID}
		DOCKERID=${DOCKERID}
		USERLOGIN=${LOGNAME}
		PASSWORD=$(mkpasswd --method=SHA-512 --stdin)
		TIMEZONE=${TZ:-$(wget -O - -q http://geoip.ubuntu.com/lookup | sed 's#.*<TimeZone>\(.*\)</TimeZone>.*#\1#')}
		I3THEME=${I3THEME:-default-light}
	EOE
	stty "${ORIGINAL_STTY}"
	echo
fi

DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 docker-compose build "$@"
