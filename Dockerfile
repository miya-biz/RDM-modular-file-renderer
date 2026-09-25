FROM python:3.5-slim-buster

# ensure unoconv can locate the uno library
ENV PYTHONPATH /usr/lib/python3/dist-packages

RUN echo "deb https://archive.debian.org/debian buster main" > /etc/apt/sources.list \
    && echo "deb https://archive.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list \
    && usermod -d /home www-data \
    && chown www-data:www-data /home \
    # -slim images strip man dirs, but java won't install unless this dir exists.
    && mkdir -p /usr/share/man/man1 \
    && apt-get update \
    # HACK: work around bug in install java (dep of libreoffice)
    && apt-get install -y ca-certificates-java \
    # mfr dependencies
    && apt-get install -y \
        git \
        make \
        gcc \
        build-essential \
        gfortran \
        r-base \
        libblas-dev \
        libevent-dev \
        libfreetype6-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff5-dev \
        libxml2-dev \
        libxslt1-dev \
        zlib1g-dev \
        # convert .step to jsc3d-compatible format
        freecad \
        # pspp dependencies
        pspp \
        # unoconv dependencies
        libreoffice \
        # grab gosu for easy step-down from root
        gosu \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && pip install -U pip \
    && pip install setuptools==37.0.0 \
    && mkdir -p /code \
    && pip install unoconv==0.8.2

WORKDIR /code

COPY ./requirements.txt ./

RUN pip install --no-cache-dir -r ./requirements.txt

# Copy the rest of the code over
COPY ./ ./

ARG GIT_COMMIT=
ENV GIT_COMMIT ${GIT_COMMIT}

RUN python setup.py develop

EXPOSE 7778

CMD ["gosu", "www-data", "invoke", "server"]
