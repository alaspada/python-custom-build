FROM ubuntu:16.04

#* Os Config: libs, srcs, utils, compilers
RUN set -ex \
    && apt-get update \ 
    && apt-get install -y --no-install-recommends file make build-essential unzip libssl-dev zlib1g-dev libbz2-dev libreadline-dev ca-certificates curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev mecab-ipadic-utf8 git

#* Os Config: fs layout
ADD ./config/base.env /var/tmp/base.env
RUN set -ex \
    && . /var/tmp/base.env \
    && mkdir -p ${CUSTOM_SRC_PATH} \
    && mkdir -p ${CUSTOM_PYTHON_DIST} 

#* Sqlite3
ADD ./config/sqlite3.env /var/tmp/sqlite3.env
RUN set -ex \
    && . /var/tmp/base.env \
    && . /var/tmp/sqlite3.env \
    && curl https://www.sqlite.org/2021/sqlite-autoconf-${SQLITE3_VER}.tar.gz > /var/tmp/sqlite3.tar.gz \
    && mkdir -p ${SQLITE3_SRC} \
    && tar xfvz /var/tmp/sqlite3.tar.gz --strip-components=1 -C ${SQLITE3_SRC} \
    && cd ${SQLITE3_SRC} \
    && CFLAGS="${SQLITE3_CFLAGS}" LIBS="-lm" ./configure --enable-shared --prefix="${SQLITE3_PREFIX}" \
    && make \
    && make install \
    && ${SQLITE3_PREFIX}/bin/sqlite3 --version

#* Python
ADD ./config/python.env /var/tmp/python.env
RUN set -ex \
    && . /var/tmp/base.env \
    && . /var/tmp/python.env \
    && mkdir -p ${CUSTOM_PYTHON_DIST} \
    && curl "https://www.python.org/ftp/python/${CUSTOM_PYTHON_VER}/Python-${CUSTOM_PYTHON_VER}.tgz" > /var/tmp/Python-${CUSTOM_PYTHON_VER}.tgz \
    && cd ${CUSTOM_SRC_PATH} \
    && tar xfvz /var/tmp/Python-${CUSTOM_PYTHON_VER}.tgz \
    && rm -rf /var/tmp/Python-${CUSTOM_PYTHON_VER}.tgz \
    && cd Python-${CUSTOM_PYTHON_VER} \
    && LD_RUN_PATH=${PYTHON_LD_RUN_PATH} ./configure --enable-shared --prefix=${CUSTOM_PYTHON_DIST} \
    && LD_RUN_PATH=${PYTHON_LD_RUN_PATH} make \
    && make install 

#* Script
ADD wpy.bash /var/tmp/wpy 
RUN set -ex \
    && mv /var/tmp/wpy ${CUSTOM_PYTHON_DIST}/bin/wpy \ 
    && chmod +x ${CUSTOM_PYTHON_DIST}/bin/wpy

# Python: testing sqlite bindings
RUN set -ex \
    && . /var/tmp/base.env \
    && . /var/tmp/python.env \
    && LD_LIBRARY_PATH="${CUSTOM_PYTHON_DIST}/lib" \
        "${CUSTOM_PYTHON_DIST}/bin/python3" -c "import sqlite3; print(sqlite3.sqlite_version)" 
