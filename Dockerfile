# Building the wfc-server
FROM golang:1.24-alpine AS wwfc-server

WORKDIR /build

# pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build

# Recreate devkitpro/devkitppc before building the patches
# This is copied as-is from the official devkitpro dockerfiles at https://github.com/devkitPro/docker/tree/master but using Debian 12 instead of 11 because 11's Python version doesn't work with the make.sh build script
# I found this easier than installing a newer python version into the current Debian 11 based image...
#FROM devkitpro/devkitppc 
FROM debian:bookworm-slim AS devkitppc-bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y --no-install-recommends sudo ca-certificates pkg-config curl wget bzip2 xz-utils make libarchive-tools doxygen gnupg && \
    apt-get install -y --no-install-recommends git git-restore-mtime && \
    apt-get install -y --no-install-recommends rsync && \
    apt-get install -y --no-install-recommends cmake zip unzip ninja-build && \
    apt-get install -y --no-install-recommends python3 python-is-python3 python3-lz4 && \
    apt-get install -y --no-install-recommends locales && \
    apt-get install -y --no-install-recommends patch && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN ln -s /proc/mounts /etc/mtab && \
    wget https://apt.devkitpro.org/install-devkitpro-pacman && \
    chmod +x ./install-devkitpro-pacman && \
    ./install-devkitpro-pacman && \
    rm ./install-devkitpro-pacman && \
    dkp-pacman -Syyu --noconfirm && \
    dkp-pacman -S --needed --noconfirm dkp-toolchain-vars dkp-meson-scripts && \
    yes | dkp-pacman -Scc


ENV LANG=en_US.UTF-8

ENV DEVKITPRO=/opt/devkitpro
ENV PATH=${DEVKITPRO}/tools/bin:$PATH

RUN dkp-pacman -Syyu --noconfirm gamecube-dev wii-dev wiiu-dev && \
    dkp-pacman -S --needed --noconfirm ppc-portlibs gamecube-portlibs wii-portlibs wiiu-portlibs && \
    dkp-pacman -S --needed --noconfirm devkitARM && \
    yes | dkp-pacman -Scc

ENV DEVKITPPC=${DEVKITPRO}/devkitPPC
ENV DEVKITARM=/opt/devkitpro/devkitARM


# Now we can use the devkitppc image to build the patches
FROM devkitppc-bookworm AS wwfc-patches

WORKDIR /build

RUN apt-get install -y python3-cryptography \
    && git clone https://github.com/WiiLink24/wfc-patcher-wii.git

WORKDIR /build/wfc-patcher-wii

ARG WWFC_DOMAIN

RUN ./make.sh --all --exploit -- -j$(nproc) -DWWFC_DOMAIN=\"${WWFC_DOMAIN}\"

# Copy everything into a clean image
FROM scratch AS final

WORKDIR /

COPY --from=wwfc-server /build/wwfc /build/game_list.tsv /build/motd.txt /
COPY --from=wwfc-patches /build/wfc-patcher-wii/dist/ /payload/
COPY --from=wwfc-patches /build/wfc-patcher-wii/exploit/sbcm/ /payload/sbcm/
COPY --from=wwfc-patches /build/wfc-patcher-wii/patch/build/*.txt /patches/

CMD ["/wwfc"]
