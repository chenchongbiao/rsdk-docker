FROM debian:12-slim as builder

ENV DEBIAN_FRONTEND=noninteractive
ARG MIRROR="mirrors.hust.edu.cn"

RUN sed -i -e "s/deb.debian.org/${MIRROR}/g" \
    -e "s|security.debian.org|${MIRROR}|g" /etc/apt/sources.list.d/debian.sources || true
RUN sed -i '/bookworm-updates/s/$/ bookworm-backports/' /etc/apt/sources.list.d/debian.sources

RUN apt-get update && \
  apt-get install -y git make clang pkgconf && \
  git clone https://github.com/google/jsonnet.git && \
  cd jsonnet && \
  make CC=clang CXX=clang++ && \
  cp jsonnet /usr/bin

FROM debian:12-slim

COPY --from=builder /usr/bin/jsonnet /usr/bin/jsonnet
ARG MIRROR="mirrors.hust.edu.cn"

RUN sed -i -e "s/deb.debian.org/${MIRROR}/g" \
    -e "s|security.debian.org|${MIRROR}|g" /etc/apt/sources.list.d/debian.sources || true
RUN sed -i '/bookworm-updates/s/$/ bookworm-backports/' /etc/apt/sources.list.d/debian.sources

RUN apt-get update && \
  apt-get install -y \
    ca-certificates sudo apt-utils bash-completion \
    bdebstrap curl dosfstools gdisk \
    jq libguestfs-tools parted gpg \
    wget xz-utils git whiptail && \
  rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1000 rsdk && \
  useradd --uid 1000 --gid 1000 -m -s /bin/bash rsdk && \
  echo 'rsdk ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/rsdk

USER rsdk
WORKDIR /home/rsdk

CMD ["/bin/bash"]
