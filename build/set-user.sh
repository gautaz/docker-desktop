#!/bin/sh
set -e

echo "Creating user ${USERLOGIN}[${USERID}:${GROUPID}]"

addgroup "${USERLOGIN}"
sed -i "s#${USERLOGIN}:x:[^:]*:#${USERLOGIN}:x:${GROUPID}:#" /etc/group
sed -i -e '$!{H;d};$G' /etc/group
adduser -h /home/user -g "container user" -s "${NIXBIN}/bash" -G "${USERLOGIN}" -D "${USERLOGIN}"
sed -i "s#${USERLOGIN}:x:[^:]*:#${USERLOGIN}:x:${USERID}:#" /etc/passwd
sed -i -e '$!{H;d};$G' /etc/passwd
chown -R "${USERID}:${GROUPID}" /home/user
