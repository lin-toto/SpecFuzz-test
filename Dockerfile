FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y libbfd-dev libunwind8-dev binutils-dev libblocksruntime-dev git

RUN apt-get install -y wget curl gcc g++ cmake make
RUN apt-get install -y xz-utils build-essential gdb vim

RUN apt-get install -y python3

COPY ./install /tmp/install
RUN INSTALL_DIR=/llvm /tmp/install/llvm.sh
RUN INSTALL_DIR=/honggfuzz /tmp/install/honggfuzz.sh

RUN cp -r /honggfuzz/honggfuzz-*/src/* /honggfuzz

COPY ./install /specfuzz/install
COPY ./Makefile /specfuzz/
COPY ./src /specfuzz/src
COPY ./tests /specfuzz/tests
COPY ./postprocessing /specfuzz/postprocessing
COPY ./example /specfuzz/example

ENV HONGG_SRC=/honggfuzz
WORKDIR /specfuzz
RUN make
RUN make install & make install_tools

RUN apt-get install -y autoconf automake libtool
RUN apt-get install -y zlib1g-dev

RUn apt-get update
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6AF7F09730B3F0A4
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg
RUN apt-get install -y software-properties-common lsb-release
RUN apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main"
RUN apt-get update && apt-get install -y cmake

#RUN dpkg --add-architecture i386 && apt-get update
#RUN apt-get install -y libc6:i386 
RUN apt-get install gcc-multilib -y

RUN apt-get install bc -y

RUN useradd --uid 1000 lin
USER lin
WORKDIR /workspace

ENV SF_CFLAGS="--enable-coverage -DNDEBUG -L/honggfuzz/libhfuzz -L/honggfuzz/libhfcommon  -lhfuzz -lhfcommon"

