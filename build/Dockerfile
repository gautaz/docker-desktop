# syntax=docker/dockerfile:experimental

FROM alpine:edge as base
RUN \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update

# https://pki-tutorial.readthedocs.io/en/latest/simple/index.html
FROM base as pki
WORKDIR /tmp
RUN apk add openssl
RUN mkdir -p ca/root-ca/private ca/root-ca/db crl certs
RUN chmod 700 ca/root-ca/private
RUN cp /dev/null ca/root-ca/db/root-ca.db
RUN cp /dev/null ca/root-ca/db/root-ca.db.attr
RUN echo 01 > ca/root-ca/db/root-ca.crt.srl
RUN echo 01 > ca/root-ca/db/root-ca.crl.srl
RUN openssl rand -base64 32 > root-ca.pwd
COPY pki/root-ca.conf etc/
RUN openssl req -batch -new \
        -config etc/root-ca.conf \
        -out ca/root-ca.csr \
        -keyout ca/root-ca/private/root-ca.key \
        -passout file:root-ca.pwd
RUN openssl ca -batch -selfsign \
        -config etc/root-ca.conf \
        -in ca/root-ca.csr \
        -out ca/root-ca.crt \
        -extensions root_ca_ext \
        -passin file:root-ca.pwd
RUN mkdir -p ca/signing-ca/private ca/signing-ca/db crl certs
RUN chmod 700 ca/signing-ca/private
RUN cp /dev/null ca/signing-ca/db/signing-ca.db
RUN cp /dev/null ca/signing-ca/db/signing-ca.db.attr
RUN echo 01 > ca/signing-ca/db/signing-ca.crt.srl
RUN echo 01 > ca/signing-ca/db/signing-ca.crl.srl
RUN openssl rand -base64 32 > signing-ca.pwd
COPY pki/signing-ca.conf etc/
RUN openssl req -batch -new \
        -config etc/signing-ca.conf \
        -out ca/signing-ca.csr \
        -keyout ca/signing-ca/private/signing-ca.key \
        -passout file:signing-ca.pwd
RUN openssl ca -batch \
        -config etc/root-ca.conf \
        -in ca/signing-ca.csr \
        -out ca/signing-ca.crt \
        -extensions signing_ca_ext \
        -passin file:root-ca.pwd
COPY pki/code-server.conf etc/
RUN SAN=DNS:code.local openssl req -batch -new \
        -config etc/code-server.conf \
        -out certs/code-server.csr \
        -keyout certs/code-server.key
RUN openssl ca -batch \
        -config etc/signing-ca.conf \
        -in certs/code-server.csr \
        -out certs/code-server.crt \
        -extensions server_ext \
        -passin file:signing-ca.pwd
RUN cat certs/code-server.crt ca/signing-ca.crt > certs/code-server-chain.crt

FROM codercom/code-server as code
ARG USERID=0
ARG GROUPID=0
ARG USERLOGIN=user
ENV USERID="${USERID}"
ENV GROUPID="${GROUPID}"
ENV USERLOGIN="${USERLOGIN}"
USER root
RUN groupadd --gid "${GROUPID}" "${USERLOGIN}"
# https://github.com/moby/moby/issues/5419
RUN useradd --no-log-init --create-home --uid "${USERID}" --gid "${GROUPID}" "${USERLOGIN}"
COPY --from=pki --chown=${USERLOGIN} ["/tmp/certs/code-server-chain.crt", "/crt.pem"]
COPY --from=pki --chown=${USERLOGIN} ["/tmp/certs/code-server.key", "/key.pem"]
USER "${USERLOGIN}"
WORKDIR "/home/${USERLOGIN}"
CMD ["--auth", "none", "--cert", "/crt.pem", "--cert-key", "/key.pem"]

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
    --mount=type=tmpfs,target=/mnt \
    --mount=type=bind,from=powerline,source=/root/go/bin,target=/mnt/powerline \
    --mount=type=bind,from=s6,source=/tmp,target=/mnt/s6 \
    --mount=type=bind,from=pki,source=/tmp,target=/mnt/pki \
    \
    apk add \
        bash \
        ca-certificates \
        dbus \
        dmenu dmenu-doc \
        eudev \
        font-xfree86-type1 \
        font-inconsolata-nerd \
        git git-bash-completion git-lfs \
        i3status i3wm i3wm-doc \
        mdocml man-pages \
        mesa-dri-swrast \
        sudo \
        ttf-freefont \
        tzdata \
        xorg-server \
        xorgxrdp \
        xrdp \
        xterm \
    && \
    echo "exec /usr/bin/dbus-run-session -- /usr/bin/i3" > /etc/X11/xinit/xinitrc.d/i3 && \
    chmod a+x /etc/X11/xinit/xinitrc.d/i3 && \
    xrdp-keygen xrdp auto && \
    cp -a /mnt/powerline/powerline-go /usr/local/bin/ && \
    gunzip -c /mnt/s6/s6-overlay-amd64.tar.gz | tar -xf - -C / && \
    cp /mnt/pki/ca/root-ca.crt /usr/local/share/ca-certificates/ca-local.pem && \
    update-ca-certificates
ENTRYPOINT ["/init"]
COPY services.d /etc/services.d
ARG USERID=0
ARG GROUPID=0
ARG AUDIOID
ARG VIDEOID
ARG DOCKERID
ARG USERLOGIN=user
ARG PASSWORD=""
ARG TIMEZONE
ENV USERID="${USERID}"
ENV GROUPID="${GROUPID}"
ENV AUDIOID="${AUDIOID}"
ENV VIDEOID="${VIDEOID}"
ENV DOCKERID="${DOCKERID}"
ENV USERLOGIN="${USERLOGIN}"
ENV PASSWORD="${PASSWORD}"
ENV TIMEZONE="${TIMEZONE}"
COPY --chown="${USERID}:${GROUPID}" ["dotfiles", "/home/${USERLOGIN}"]
RUN \
    --mount=type=tmpfs,target=/mnt \
    --mount=type=bind,from=local,source=/tmp,target=/mnt/local \
    --mount=type=bind,from=i3theme,source=/tmp,target=/mnt/i3theme \
    \
    echo "TZ=${TIMEZONE}" >> /etc/xrdp/sesman.ini && \
    cat /mnt/i3theme/config >> "/home/${USERLOGIN}/.config/i3/config" && \
    /mnt/local/add-user.sh
