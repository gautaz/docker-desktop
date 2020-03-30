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

FROM busybox as s6
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.8.0/s6-overlay-amd64.tar.gz /tmp/

# FROM busybox as xorg-dummy-conf
# ADD https://xpra.org/xorg.conf /tmp/

# FROM base as xf86-input-void
# RUN apk add --update-cache autoconf automake build-base git libtool util-macros xorg-server-dev
# WORKDIR /tmp
# RUN git clone https://gitlab.freedesktop.org/xorg/driver/xf86-input-void.git
# WORKDIR /tmp/xf86-input-void
# RUN autoreconf --install
# RUN ./configure --prefix=/tmp/install
# RUN make install

# FROM base as xorgxrdp
# RUN apk add --update-cache autoconf automake build-base git libtool nasm pkgconfig util-macros xorg-server-dev xrdp-dev@ecommunity
# WORKDIR /tmp
# RUN git clone https://github.com/neutrinolabs/xorgxrdp.git
# WORKDIR /tmp/xorgxrdp
# RUN ./bootstrap
# RUN ./configure --prefix=/tmp/install
# RUN make install
# ENTRYPOINT ["tail", "-f", "/dev/null"]

FROM base
ARG USERID=0
ARG GROUPID=0
ARG USERLOGIN=user
ENV USERID="${USERID}"
ENV GROUPID="${GROUPID}"
ENV USERLOGIN="${USERLOGIN}"
RUN \
    --mount=type=bind,from=local,source=/tmp,target=/mnt/local \
    --mount=type=bind,from=s6,source=/tmp,target=/mnt/s6 \
    # --mount=type=bind,from=xorg-dummy-conf,source=/tmp,target=/mnt/xorg-dummy-conf \
    # --mount=type=bind,from=xf86-input-void,source=/tmp/install,target=/mnt/xf86-input-void \
    \
    apk add \
        bash \
        eudev \
        git git-bash-completion git-lfs \
        i3wm \
        man man-pages \
        powerline-extra-symbols@etesting \
        ttf-freefont \
        # xorg-server xf86-video-dummy mesa-dri-swrast \
        xorg-server@emain mesa-dri-swrast \
        xrdp@ecommunity xorgxrdp@etesting \
        xterm \
    && \
    # tar cf - -C /mnt/xf86-input-void . | tar xf - -C /usr && \
    # cp /mnt/xorg-dummy-conf/xorg.conf /etc/X11 && \
    echo "exec /usr/bin/i3" > /etc/X11/xinit/xinitrc.d/i3 && \
    chmod a+x /etc/X11/xinit/xinitrc.d/i3 && \
    xrdp-keygen xrdp auto && \
    /mnt/local/add-user.sh && \
    gunzip -c /mnt/s6/s6-overlay-amd64.tar.gz | tar -xf - -C /
ENTRYPOINT ["/init"]
COPY services.d /etc/services.d
COPY --chown="${USERID}:${GROUPID}" dotfiles /home/user
