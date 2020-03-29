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
    echo "${NIXBIN}/bash" >> /etc/shells && \
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
RUN source /etc/profile.d/nix.sh && \
    ln -s /dev/null /home/user/.nix-defexpr/channels && \
    nix-env --switch-profile "/nix/var/nix/profiles/per-user/${USERLOGIN}/profile" && \
    nix-env --install --attr $(echo "\
        bashInteractive_5 \
        gitAndTools.gitFull \
        haskellPackages.xmonad \
        man \
        nix \
        powerline-fonts \
        powerline-go \
        screen \
        x11vnc \
        xterm \
        xvfb_run \
    " | tr -s ' ' '\n' | sed '/^$/d;s/\(.*\)/nixpkgs.\1/' | tr '\n' ' ') && \
    nix-collect-garbage
COPY --chown="${USERID}:${GROUPID}" dotfiles /home/user

USER root
ENV HOME="/root"
ENV USER="root"
WORKDIR /root
COPY services.d /etc/services.d
ENTRYPOINT ["/init"]
