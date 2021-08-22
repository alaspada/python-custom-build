FROM ubuntu:16.04

#Set of all dependencies needed for pyenv to work on Ubuntu
RUN apt-get update \ 
        && apt-get install -y --no-install-recommends make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget ca-certificates curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev mecab-ipadic-utf8 git

# Set-up necessary Env vars for PyEnv
ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

ENV CUSTOM_PYTHON_DIST=/opt/python
ARG CUSTOM_PYTHON_VER=3.9.0
ENV PYTHON_CONFIGURE_OPTS="--enable-shared"
ENV PATH $CUSTOM_PYTHON_DIST/bin:$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
ENV PIP_NO_WARN_SCRIPT_LOCATION=true

# Install pyenv
RUN set -ex \
    && mkdir -p ${CUSTOM_PYTHON_DIST} \
    && curl https://pyenv.run | bash \
    && pyenv update \
    && pyenv install $CUSTOM_PYTHON_VER \
    && pyenv global $CUSTOM_PYTHON_VER \
    && pyenv rehash

# Optional : Checks Pyenv version on container start-up
ENTRYPOINT [ "pyenv","version" ]
