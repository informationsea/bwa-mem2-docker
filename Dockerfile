FROM debian:10 as download-bwa
RUN apt-get update -y && apt-get install -y curl tar bzip2
RUN curl -OL https://github.com/bwa-mem2/bwa-mem2/releases/download/v2.1/bwa-mem2-2.1_x64-linux.tar.bz2
RUN tar xjf bwa-mem2-2.1_x64-linux.tar.bz2

FROM debian:10 as download-samtools
RUN apt-get update -y && apt-get install -y curl tar bzip2
RUN curl -OL https://github.com/samtools/samtools/releases/download/1.11/samtools-1.11.tar.bz2
RUN tar xjf samtools-1.11.tar.bz2

FROM debian:10 as build-samtools
RUN apt-get update -y && apt-get install -y tar build-essential libncurses-dev libcurl4-openssl-dev liblzma-dev libbz2-dev zlib1g-dev
COPY --from=download-samtools /samtools-1.11 /samtools-1.11
WORKDIR /samtools-1.11
RUN ./configure
RUN make -j4
RUN make install

FROM debian:10-slim
RUN apt-get update -y && apt-get install -y libncurses5 libcurl4 liblzma5 bzip2 zlib1g libdigest-perl-md5-perl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
COPY --from=download-bwa /bwa-mem2-2.1_x64-linux /opt/bwa-mem2-2.1_x64-linux
COPY --from=build-samtools /usr/local /usr/local
ENV PATH=/opt/bwa-mem2-2.1_x64-linux:$PATH