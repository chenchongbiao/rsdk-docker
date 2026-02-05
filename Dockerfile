FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i -e 's/deb.debian.org/mirrors.aliyun.com/g' \
    -e 's|deb.debian.org/debian-security|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources|| true
RUN sed -i '/bookworm-updates/s/$/ bookworm-backports/' /etc/apt/sources.list.d/debian.sources

RUN apt-get update && \
  apt-get install -y \
    ca-certificates sudo apt-utils bash-completion \
    bdebstrap curl dosfstools gdisk jsonnet \
    jq libguestfs-tools parted gpg \
    wget xz-utils git whiptail && \
  rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1000 rsdk && \
  useradd --uid 1000 --gid 1000 -m -s /bin/bash rsdk && \
  echo 'rsdk ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/rsdk

USER rsdk
WORKDIR /home/rsdk

CMD ["/bin/bash"]
