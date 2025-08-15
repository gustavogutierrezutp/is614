FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV QUARTUS_INSTALL_DIR=/opt/intel/quartus

RUN dpkg --add-architecture amd64 && apt-get update && \
    apt-get install -y \
    libbz2-1.0:amd64 binutils:amd64 libglib2.0-0:amd64 libnsl-dev:amd64 g++-multilib:amd64 \
    libfontconfig1:amd64 libx11-xcb1:amd64 libxext6:amd64 libsm6:amd64 libdbus-1-3:amd64 \
    libxft2:amd64 libxtst6:amd64 libxi6:amd64 libgtk2.0-0:amd64 wget tar xz-utils

RUN mkdir -p $QUARTUS_INSTALL_DIR
WORKDIR /tmp

RUN wget https://downloads.intel.com/akdlm/software/acdsinst/24.1std/1077/ib_tar/Quartus-lite-24.1std.0.1077-linux.tar

RUN tar xf Quartus-lite-24.1std.0.1077-linux.tar

RUN chmod +x setup.sh && \
    ./setup.sh --mode unattended --accept_eula 1 --installdir $QUARTUS_INSTALL_DIR \
    --disable-components quartus_help,arria_lite,cyclone10lp,max,max10,riscfree --create_desktop_shortcuts 0

RUN rm -rf /tmp/*

ENV PATH=$QUARTUS_INSTALL_DIR/quartus/bin:$PATH
ENV LD_LIBRARY_PATH=$QUARTUS_INSTALL_DIR/quartus/linux64:$LD_LIBRARY_PATH

WORKDIR /workspace

CMD ["quartus"]
