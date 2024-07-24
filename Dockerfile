FROM debian:12-slim as download-bwa
ARG BWAMEM2_VERSION=2.2.1
RUN apt-get update -y && apt-get install -y curl tar bzip2
RUN curl -OL https://github.com/bwa-mem2/bwa-mem2/releases/download/v${BWAMEM2_VERSION}/bwa-mem2-${BWAMEM2_VERSION}_x64-linux.tar.bz2
RUN tar --no-same-owner -xjf bwa-mem2-${BWAMEM2_VERSION}_x64-linux.tar.bz2

FROM debian:12 as download-samtools
ARG SAMTOOLS_VERSION=1.20
RUN apt-get update -y && apt-get install -y curl tar bzip2
RUN curl -OL https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2
RUN tar --no-same-owner -xjf samtools-${SAMTOOLS_VERSION}.tar.bz2

FROM debian:12 as build-samtools
ARG SAMTOOLS_VERSION=1.20
RUN apt-get update -y && apt-get install -y tar build-essential libncurses-dev libcurl4-openssl-dev liblzma-dev libbz2-dev zlib1g-dev
COPY --from=download-samtools /samtools-${SAMTOOLS_VERSION} /samtools-${SAMTOOLS_VERSION}
WORKDIR /samtools-${SAMTOOLS_VERSION}
RUN ./configure
RUN make -j4
RUN make install

FROM debian:12-slim
RUN apt-get update -y && apt-get install -y libncurses5 libcurl4 liblzma5 bzip2 zlib1g libdigest-perl-md5-perl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
ARG BWAMEM2_VERSION=2.2.1
COPY --from=download-bwa /bwa-mem2-${BWAMEM2_VERSION}_x64-linux /opt/bwa-mem2-${BWAMEM2_VERSION}_x64-linux
COPY --from=build-samtools /usr/local /usr/local
ENV PATH=/opt/bwa-mem2-${BWAMEM2_VERSION}_x64-linux:$PATH
