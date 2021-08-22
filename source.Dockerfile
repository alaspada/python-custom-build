FROM ubuntu:16.04

#* Os Config: libs
RUN \
    apt-get update \ 
    && apt-get install -y --no-install-recommends make build-essential unzip libssl-dev zlib1g-dev libbz2-dev libreadline-dev ca-certificates curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev mecab-ipadic-utf8 git

#* Os Config: fs layout
ADD ./config/base.env /var/tmp/base.env
RUN set -ex \
    && . /var/tmp/base.env \
    && mkdir -p ${CUSTOM_SRC_PATH}

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
    && make install

#* Python
ADD ./config/python.env /var/tmp/python.env
RUN set -ex \
    && . /var/tmp/base.env \
    && . /var/tmp/python.env \
    && mkdir -p ${CUSTOM_PYTHON_DIST} \
    && curl "https://www.python.org/ftp/python/${CUSTOM_PYTHON_VER}/Python-${CUSTOM_PYTHON_VER}.tgz" > /var/tmp/Python-${CUSTOM_PYTHON_VER}.tgz \
    && tar xfvz /var/tmp/Python-${CUSTOM_PYTHON_VER}.tgz \
    && rm -rf /var/tmp/Python-${CUSTOM_PYTHON_VER}.tgz \
    && cd Python-${CUSTOM_PYTHON_VER} \
    && ./configure --enable-shared --prefix=${CUSTOM_PYTHON_DIST} \
    && make \
    && make install \
    && ls -lart ${CUSTOM_PYTHON_DIST}

#* Script
ADD wpy.bash /var/tmp/wpy 
RUN set -ex \
    && . /var/tmp/base.env \
    && . /var/tmp/python.env \
    && mv /var/tmp/wpy ${CUSTOM_PYTHON_DIST}/bin/wpy \ 
    && chmod +x ${CUSTOM_PYTHON_DIST}/bin/wpy
