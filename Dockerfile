# Stage 1: Build
FROM archlinux:latest AS builder

RUN pacman -Syu --noconfirm \
    base-devel git cmake mariadb mariadb-libs boost boost-libs

WORKDIR /build

RUN git clone https://github.com/cmangos/mangos-classic.git mangos

RUN mkdir build && cd build && \
    cmake ../mangos \
        -DCMAKE_INSTALL_PREFIX=/opt/mangos \
        -DBUILD_EXTRACTORS=ON \
        -DBUILD_PLAYERBOTS=ON \
        -DBUILD_AHBOT=ON \
        -DPCH=1 \
        -DDEBUG=0 && \
    make -j$(nproc) && \
    make install

# Configs vorbereiten
# ahbot.conf aus Quellcode (nicht .dist) um "Too few values" Fehler zu vermeiden
RUN cd /opt/mangos/etc && \
    cp mangosd.conf.dist mangosd.conf && \
    cp realmd.conf.dist realmd.conf && \
    cp anticheat.conf.dist anticheat.conf && \
    cp /build/mangos/src/game/AuctionHouseBot/ahbot.conf.dist.in ahbot.conf

# aiplayerbot.conf in das Verzeichnis kopieren das SYSCONFDIR zur Laufzeit
# aufloest (/opt/etc/ — relativ zur Binary in /opt/mangos/bin/)
# Ohne diese Datei startet der Server mit "AI Playerbot is Disabled"
RUN mkdir -p /opt/etc && \
    cp /opt/mangos/etc/aiplayerbot.conf.dist /opt/etc/aiplayerbot.conf

# Stage 2: Runtime
FROM archlinux:latest AS runtime

RUN pacman -Syu --noconfirm \
    mariadb-libs mariadb-clients boost-libs openssl

COPY --from=builder /opt/mangos /opt/mangos
COPY --from=builder /opt/etc /opt/etc

WORKDIR /opt/mangos