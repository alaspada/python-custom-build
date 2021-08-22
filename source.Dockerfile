FROM ubuntu:16.04

# Set of all dependencies needed to build python on Ubuntu
RUN \
    apt-get update \ 
    && apt-get install -y --no-install-recommends make build-essential unzip libssl-dev zlib1g-dev libbz2-dev libreadline-dev ca-certificates curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev mecab-ipadic-utf8 git

ADD ./config/base.env /var/tmp/base.env

RUN set -ex \
    && source /var/tmp/base.env \
    && mkdir -p ${CUSTOM_SRC_PATH}


# Install sqlite3: download source
ENV SQLITE3_SRC=${CUSTOM_SRC_PATH}/sqlite3/

RUN set -ex \
    && curl https://www.sqlite.org/2021/sqlite-autoconf-${SQLITE3_VER}.tar.gz > /var/tmp/sqlite3.tar.gz 

ENV SQLITE3_PREFIX=${CUSTOM_PYTHON_DIST}
ENV SQLITE3_CFLAGS="-DSQLITE_ENABLE_FTS3 \
    -DSQLITE_ENABLE_FTS3_PARENTHESIS \
    -DSQLITE_ENABLE_FTS4 \
    -DSQLITE_ENABLE_FTS5 \
    -DSQLITE_ENABLE_JSON1 \
    -DSQLITE_ENABLE_LOAD_EXTENSION \
    -DSQLITE_ENABLE_RTREE \
    -DSQLITE_ENABLE_STAT4 \
    -DSQLITE_ENABLE_UPDATE_DELETE_LIMIT \
    -DSQLITE_SOUNDEX \
    -DSQLITE_TEMP_STORE=3 \
    -DSQLITE_USE_URI \
    -O2 \
    -fPIC"

RUN set -ex \
    && mkdir -p ${SQLITE3_SRC} \
    && tar xfvz /var/tmp/sqlite3.tar.gz --strip-components=1 -C ${SQLITE3_SRC} \
    && cd ${SQLITE3_SRC} \
    && CFLAGS="${SQLITE3_CFLAGS}" LIBS="-lm" ./configure --enable-shared --prefix="${SQLITE3_PREFIX}" \
    && make \
    && make install

ARG CUSTOM_PYTHON_VER=3.9.0
ENV PYTHON_LD_RUN_PATH="${CUSTOM_PYTHON_DIST}/lib"
ENV PYTHON_LDFLAGS="-L${CUSTOM_PYTHON_DIST}/lib"
ENV PYTHON_CPPFLAGS="-I${CUSTOM_PYTHON_DIST}/include"
ENV PYTHON_CONFIGURE_OPTS="--enable-shared LDFLAGS=${PYTHON_LDFLAGS} CPPFLAGS=${PYTHON_CPPFLAGS}"
ENV PATH $CUSTOM_PYTHON_DIST/bin:$PATH
ENV PIP_NO_WARN_SCRIPT_LOCATION=true

# Install python: download source
RUN set -ex \
    && mkdir -p ${CUSTOM_PYTHON_DIST} \
    && curl "https://www.python.org/ftp/python/${CUSTOM_PYTHON_VER}/Python-${CUSTOM_PYTHON_VER}.tgz" > /var/tmp/Python-${CUSTOM_PYTHON_VER}.tgz \
    && tar xfvz /var/tmp/Python-${CUSTOM_PYTHON_VER}.tgz \
    && rm -rf /var/tmp/Python-${CUSTOM_PYTHON_VER}.tgz 

# Install python: build from source
RUN set -ex \
    && cd Python-${CUSTOM_PYTHON_VER} \
    && LD_RUN_PATH=${PYTHON_LD_RUN_PATH} ./configure --enable-shared --prefix=${CUSTOM_PYTHON_DIST} \
    && LD_RUN_PATH=${PYTHON_LD_RUN_PATH}  make \
    && make install \
    && ls -lart ${CUSTOM_PYTHON_DIST}

ADD wp.bash ${CUSTOM_PYTHON_DIST}/bin/wp
RUN set -ex \
    chmod +x ${CUSTOM_PYTHON_DIST}/bin/wp
