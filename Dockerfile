FROM debian:buster-slim

ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LANG=C.UTF-8
ENV PYTHONIOENCODING=UTF-8
ENV PYTHON_VERSION=2.7.18

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates netbase && rm -rf /var/lib/apt/lists/*
# ENV GPG_KEY=C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF

RUN set -ex \ 
    && savedAptMark="$(apt-mark showmanual)" \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        dpkg-dev gcc libbz2-dev libc6-dev libdb-dev libgdbm-dev \
        libncursesw5-dev libreadline-dev libsqlite3-dev libssl-dev \
        make tk-dev wget xz-utils zlib1g-dev \
        $(command -v gpg > /dev/null || echo 'gnupg dirmngr') \
    && wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
    # && wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
    # && export GNUPGHOME="$(mktemp -d)" && gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" && gpg --batch --verify python.tar.xz.asc python.tar.xz && { command -v gpgconf > /dev/null && gpgconf --kill all || :; } && rm -rf "$GNUPGHOME" python.tar.xz.asc \
    && mkdir -p /usr/src/python && tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz && rm python.tar.xz \
    && cd /usr/src/python \
    && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
    && ./configure --build="$gnuArch" --with-pydebug --enable-option-checking=fatal --enable-shared --enable-unicode=ucs4 \
    && make -j "$(nproc)" PROFILE_TASK='-m test.regrtest --pgo test_array test_base64 test_binascii test_binhex test_binop test_bytes test_c_locale_coercion test_class test_cmath test_codecs test_compile test_complex test_csv test_decimal test_dict test_float test_fstring test_hashlib test_io test_iter test_json test_long test_math test_memoryview test_pickle test_re test_set test_slice test_struct test_threading test_time test_traceback test_unicode ' \
    && make install && mkdir /gdb && touch /gdb/__init__.py && cp /usr/src/python/python-gdb.py /gdb/libpython.py && ldconfig \
    && apt-mark auto '.*' > /dev/null && apt-mark manual $savedAptMark \
    && find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec ldd '{}' ';' | awk '/=>/ { print $(NF-1) }' | sort -u | xargs -r dpkg-query --search | cut -d: -f1 | sort -u | xargs -r apt-mark manual \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* \
    && find /usr/local -depth \( \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \) -exec rm -rf '{}' + \
    && rm -rf /usr/src/python \
    && python2 --version

RUN set -ex && apt-get update && apt-get install -y --no-install-recommends gdb python2.7-dbg procps
COPY gdbinit /root/.gdbinit

ENV PYTHON_PIP_VERSION=20.0.2
ENV PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/d59197a3c169cef378a22428a3fa99d33e080a5d/get-pip.py
ENV PYTHON_GET_PIP_SHA256=421ac1d44c0cf9730a088e337867d974b91bdce4ea2636099275071878cc189e
RUN set -ex; savedAptMark="$(apt-mark showmanual)"; apt-get update; apt-get install -y --no-install-recommends wget; wget -O get-pip.py "$PYTHON_GET_PIP_URL"; echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum --check --strict -; apt-mark auto '.*' > /dev/null; [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; rm -rf /var/lib/apt/lists/*; python get-pip.py --disable-pip-version-check --no-cache-dir "pip==$PYTHON_PIP_VERSION" ; pip --version; find /usr/local -depth \( \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \) -exec rm -rf '{}' +; rm -f get-pip.py

CMD ["python2"]
