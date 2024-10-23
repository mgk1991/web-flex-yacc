FROM alpine:3.19 AS builder

# Install all build dependencies
RUN apk add --no-cache \
    cmake \
    make \
    gcc \
    g++ \
    git \
    pkgconfig \
    json-c-dev \
    linux-headers \
    libuv-dev \
    util-linux-dev \
    musl-dev \
    zlib-dev \
    openssl-dev \
    ncurses-dev \
    libevent-dev \
    autoconf \
    automake \
    bison \
    wget

# Build libwebsockets
RUN git clone https://github.com/warmcat/libwebsockets.git && \
    cd libwebsockets && \
    mkdir build && \
    cd build && \
    cmake -DLWS_WITH_LIBUV=ON .. && \
    make && \
    make install

# Build ttyd
RUN git clone https://github.com/tsl0922/ttyd.git && \
    cd ttyd && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Debug .. && \
    make && \
    make install

# Build lrzsz
RUN wget https://ohse.de/uwe/releases/lrzsz-0.12.20.tar.gz && \
    tar xf lrzsz-0.12.20.tar.gz && \
    cd lrzsz-0.12.20 && \
    ./configure && \
    make && \
    make install && \
    ln -sf /usr/local/bin/lrz /usr/local/bin/rz && \
    ln -sf /usr/local/bin/lsz /usr/local/bin/sz

# Final stage
FROM alpine:3.19

# Install runtime dependencies
RUN apk add --no-cache \
    bash \
    nano \
    flex \
    bison \
    gcc \
    make \
    json-c \
    libuv \
    musl-dev \
    zlib \
    openssl \
    ncurses \
    libevent \
    build-base \
    shadow

# Copy compiled binaries and libraries
COPY --from=builder /usr/local/bin/ttyd /usr/local/bin/
COPY --from=builder /usr/local/bin/lrz /usr/local/bin/
COPY --from=builder /usr/local/bin/lsz /usr/local/bin/
COPY --from=builder /usr/local/lib/lib*.so* /usr/local/lib/

# Create symbolic links for rz/sz
RUN ln -sf /usr/local/bin/lrz /usr/local/bin/rz && \
    ln -sf /usr/local/bin/lsz /usr/local/bin/sz

# Configure ldconfig
RUN ldconfig /usr/local/lib || true

# Verify that required binaries are available
RUN bash --version && \
    which ttyd && \
    which bash && \
    which rz && \
    which sz

# Create non-root user
RUN adduser -D -u 1000 ttyd && \
    addgroup ttyd wheel

# Create working directory
RUN mkdir -p /home/ttyd/workspace && \
    chown -R ttyd:ttyd /home/ttyd

# Create wrapper scripts for rz and sz
RUN echo '#!/bin/bash' > /usr/local/bin/rz-wrapper.sh && \
    echo 'printf "\033[?25h"' >> /usr/local/bin/rz-wrapper.sh && \
    echo 'rz -e -b' >> /usr/local/bin/rz-wrapper.sh && \
    echo '#!/bin/bash' > /usr/local/bin/sz-wrapper.sh && \
    echo 'printf "\033[?25h"' >> /usr/local/bin/sz-wrapper.sh && \
    echo 'sz -e -b "$@"' >> /usr/local/bin/sz-wrapper.sh && \
    chmod 755 /usr/local/bin/rz-wrapper.sh && \
    chmod 755 /usr/local/bin/sz-wrapper.sh

# Script to create unique temporary directory per session
RUN echo '#!/bin/bash' > /usr/local/bin/new-session.sh && \
    echo 'SESSION_DIR=$(mktemp -d -p /home/ttyd/workspace)' >> /usr/local/bin/new-session.sh && \
    echo 'echo "Welcome to Web Flex & YACC/Bison Development Environment"' >> /usr/local/bin/new-session.sh && \
    echo 'echo "File transfer commands:"' >> /usr/local/bin/new-session.sh && \
    echo 'echo " - Use rz to upload files"' >> /usr/local/bin/new-session.sh && \
    echo 'echo " - Use sz <filename> to download"' >> /usr/local/bin/new-session.sh && \
    echo 'echo "Uploaded and created files will be available in current directory"' >> /usr/local/bin/new-session.sh && \
    echo 'echo "NOTE: This is a temporary session. All files will be deleted on close."' >> /usr/local/bin/new-session.sh && \
    echo 'echo "-------------------------------------------"' >> /usr/local/bin/new-session.sh && \
    echo 'cd "$SESSION_DIR"' >> /usr/local/bin/new-session.sh && \
    echo 'exec bash' >> /usr/local/bin/new-session.sh && \
    chmod 755 /usr/local/bin/new-session.sh && \
    chown ttyd:ttyd /usr/local/bin/new-session.sh

# Switch to non-root user
USER ttyd
WORKDIR /home/ttyd

# Configure environment variables
ENV TERM=xterm-256color
ENV SHELL=/bin/bash
ENV HOME=/home/ttyd
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

CMD ["/usr/local/bin/ttyd", "--port", "7681", "--writable", "--client-option", "fontSize=20", "--client-option", "enableZmodem=true", "/usr/local/bin/new-session.sh"]

EXPOSE 7681
