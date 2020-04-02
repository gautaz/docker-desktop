# syntax=docker/dockerfile:experimental

FROM alpine:3.11 as base
RUN \
    echo -e " \
        @emain http://dl-cdn.alpinelinux.org/alpine/edge/main \n\
        @ecommunity http://dl-cdn.alpinelinux.org/alpine/edge/community \n\
        @etesting http://dl-cdn.alpinelinux.org/alpine/edge/testing \n\
    " | awk '{print $1" "$2}' >> /etc/apk/repositories && \
    apk update

FROM busybox as local
COPY add-user.sh /tmp/

FROM busybox as i3theme
ARG I3THEME
ADD https://raw.githubusercontent.com/khamer/base16-i3/master/themes/base16-${I3THEME}.config /tmp/config

FROM busybox as s6
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.8.0/s6-overlay-amd64.tar.gz /tmp/

FROM base as powerline
RUN apk add git go
RUN go get -u github.com/justjanne/powerline-go

FROM base
RUN \
    --mount=type=bind,from=powerline,source=/root/go/bin,target=/mnt/powerline \
    --mount=type=bind,from=s6,source=/tmp,target=/mnt/s6 \
    \
    apk add \
        bash \
        eudev \
        git git-bash-completion git-lfs \
        i3status i3wm \
        man man-pages \
        powerline-extra-symbols@etesting \
        sudo \
        ttf-freefont \
        tzdata \
        xorg-server@emain mesa-dri-swrast \
        xrdp@ecommunity xorgxrdp@etesting \
        xterm \
    && \
    echo "exec /usr/bin/i3" > /etc/X11/xinit/xinitrc.d/i3 && \
    chmod a+x /etc/X11/xinit/xinitrc.d/i3 && \
    xrdp-keygen xrdp auto && \
    cp -a /mnt/powerline/powerline-go /usr/local/bin/ && \
    gunzip -c /mnt/s6/s6-overlay-amd64.tar.gz | tar -xf - -C /
ENTRYPOINT ["/init"]
COPY services.d /etc/services.d
ARG USERID=0
ARG GROUPID=0
ARG USERLOGIN=user
ARG PASSWORD=""
ARG TIMEZONE
ENV USERID="${USERID}"
ENV GROUPID="${GROUPID}"
ENV USERLOGIN="${USERLOGIN}"
ENV PASSWORD="${PASSWORD}"
ENV TIMEZONE="${TIMEZONE}"
COPY --chown="${USERID}:${GROUPID}" ["dotfiles", "/home/${USERLOGIN}"]
RUN \
    --mount=type=bind,from=local,source=/tmp,target=/mnt/local \
    --mount=type=bind,from=i3theme,source=/tmp,target=/mnt/i3theme \
    \
    echo "TZ=${TIMEZONE}" >> /etc/xrdp/sesman.ini && \
    cat /mnt/i3theme/config >> "/home/${USERLOGIN}/.config/i3/config" && \
    /mnt/local/add-user.sh
