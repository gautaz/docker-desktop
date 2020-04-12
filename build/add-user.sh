#!/bin/sh
set -e

setGroupId() {
	local name=$1
	local id=$2
	if [ -n "${id}" ]; then
		sed -i "s#^${name}:x:[^:]*:#${name}:x:${id}:#" /etc/group
	fi
}

setGroupId audio "${AUDIOID}"
setGroupId video "${VIDEOID}"

addgroup docker
setGroupId docker "${DOCKERID}"

addgroup "${USERLOGIN}"
setGroupId "${USERLOGIN}" "${GROUPID}"
sed -i -e '$!{H;d};$G' /etc/group

adduser -h "/home/${USERLOGIN}" -g "container user" -s "/bin/bash" -G "${USERLOGIN}" -D "${USERLOGIN}"
for group in audio video docker; do
	adduser "${USERLOGIN}" "${group}"
done
sed -i "s#^${USERLOGIN}:x:[^:]*:#${USERLOGIN}:x:${USERID}:#" /etc/passwd
sed -i -e '$!{H;d};$G' /etc/passwd
chown -R "${USERID}:${GROUPID}" "/home/${USERLOGIN}"

sed -i "s#^${USERLOGIN}:[^:]*:#${USERLOGIN}:${PASSWORD}:#" /etc/shadow

echo "${USERLOGIN} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/user
