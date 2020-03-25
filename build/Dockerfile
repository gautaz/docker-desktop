# syntax=docker/dockerfile:experimental

FROM busybox as tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.8.0/s6-overlay-amd64.tar.gz /tmp/
COPY set-user.sh /tmp/


FROM nixos/nix
ARG USERID=0
ARG GROUPID=0
ARG USERLOGIN=user

ENV USERID="${USERID}"
ENV GROUPID="${GROUPID}"
ENV USERLOGIN="${USERLOGIN}"
ENV NIXBIN="/home/user/.nix-profile/bin"
RUN --mount=type=bind,from=tmp,source=/tmp,target=/mnt \
    /mnt/set-user.sh && \
    adduser "${USERLOGIN}" nixbld && \
    nixvar="/nix/var" && \
    chgrp -R "${GROUPID}" "${nixvar}" && \
    chmod -R g+rw "${nixvar}" && \
    gunzip -c /mnt/s6-overlay-amd64.tar.gz | tar -xf - -C /

USER ${USERLOGIN}
ENV HOME="/home/user"
ENV USER="${USERLOGIN}"
WORKDIR /home/user
RUN source /etc/profile.d/nix.sh && nix-env --switch-profile "/nix/var/nix/profiles/per-user/${USERLOGIN}/profile" && \
    nix-env --install --attr \
        nixpkgs.bash \
        nixpkgs.man \
        nixpkgs.xvfb_run \
        nixpkgs.x11vnc \
        nixpkgs.haskellPackages.xmonad \
        nixpkgs.xterm \
    && \
    nix-collect-garbage

USER root
ENV HOME="/root"
ENV USER="root"
WORKDIR /root
COPY services.d /etc/services.d
ENTRYPOINT ["/init"]
