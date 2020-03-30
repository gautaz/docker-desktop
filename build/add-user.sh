#!/bin/sh
set -e

addgroup "${USERLOGIN}"
sed -i "s#${USERLOGIN}:x:[^:]*:#${USERLOGIN}:x:${GROUPID}:#" /etc/group
sed -i -e '$!{H;d};$G' /etc/group

adduser -h /home/user -g "container user" -s "/bin/bash" -G "${USERLOGIN}" -D "${USERLOGIN}"
sed -i "s#${USERLOGIN}:x:[^:]*:#${USERLOGIN}:x:${USERID}:#" /etc/passwd
sed -i -e '$!{H;d};$G' /etc/passwd
chown -R "${USERID}:${GROUPID}" /home/user
