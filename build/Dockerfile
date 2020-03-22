# syntax=docker/dockerfile:experimental

FROM busybox as tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.8.0/s6-overlay-amd64.tar.gz /tmp/
COPY set-user.sh /tmp/

FROM nixos/nix
ARG USERID=0
ARG GROUPID=0
ARG USERLOGIN=user
RUN --mount=type=bind,from=tmp,source=/tmp,target=/mnt \
    /mnt/set-user.sh "${USERID}" "${GROUPID}" "${USERLOGIN}" && \
    gunzip -c /mnt/s6-overlay-amd64.tar.gz | tar -xf - -C / && \
    nix-env --install --attr \
        nixpkgs.man \
        nixpkgs.bash_5 \
        nixpkgs.xvfb_run \
        nixpkgs.x11vnc \
        nixpkgs.haskellPackages.xmonad \
        nixpkgs.xterm
COPY services.d /etc/services.d
ENV USERLOGIN=${USERLOGIN}
ENTRYPOINT ["/init"]
