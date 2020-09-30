FROM debian:10

RUN apt update \
    && apt -y install \
        build-essential \
        libncurses5-dev \
        libncursesw5-dev \
        zlib1g-dev gawk \
        git \
        gettext \
        libssl-dev \
        xsltproc \
        wget \
        unzip \
        python3 \
    && rm -rf /var/lib/apt/lists/*

COPY /work/imagebuilder /openwrt-imagebuilder

WORKDIR /openwrt-imagebuilder

ENTRYPOINT ["make"]
