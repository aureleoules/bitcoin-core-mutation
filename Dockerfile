FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y build-essential libtool autotools-dev automake pkg-config bsdmainutils python3 libevent-dev libboost-dev libsqlite3-dev python3-pip ccache git curl wget

RUN ccache -F 1000000000 && ccache -M 1000000000
RUN pip3 install universalmutator
WORKDIR /mutation
RUN git clone https://github.com/bitcoin/bitcoin.git
RUN cd bitcoin && \
    ./contrib/install_db4.sh `pwd` && \
    export BDB_PREFIX='/mutation/bitcoin/db4' && \
    ./autogen.sh && \
    ./configure --disable-fuzz --enable-fuzz-binary=no --with-gui=no --disable-zmq --disable-bench BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" BDB_CFLAGS="-I${BDB_PREFIX}/include" && \
    make -j$(nproc)

RUN rm -rf bitcoin-core-mutation
COPY . bitcoin-core-mutation
ENTRYPOINT /mutation/bitcoin-core-mutation/run.sh