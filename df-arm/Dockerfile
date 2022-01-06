FROM --platform=linux/arm64 jupyter/scipy-notebook 

ENV PATH=$PATH:/usr/share/perl6/site/bin

USER root
RUN buildDeps="libc6-dev libencode-perl libzstd-dev libssl-dev \
               libbz2-dev libreadline-dev libsqlite3-dev llvm \
               libncurses5-dev tk-dev liblzma-dev \
               python-openssl python3-dev libpython3.9-dev" \
    && apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends build-essential curl wget $buildDeps \
    && rm -rf /var/lib/apt/lists/* 

RUN mkdir rakudo && git init \
    && wget -O rakudo.tar.gz https://github.com/rakudo/rakudo/releases/download/2021.05/rakudo-2021.05.tar.gz \
    && tar xzf rakudo.tar.gz --strip-components=1 -C rakudo \
    && ( \ 
        cd rakudo \
        && perl Configure.pl --prefix=/usr --gen-moar --gen-nqp \
        --backends=moar --moar-option='--toolchain=gnu' --relocatable \
        && make && make install \
    ) \ 
    && rm -rf rakudo rakudo.tar.gz \
    && git clone -b master --single-branch https://github.com/ugexe/zef.git \
    && cd zef \
    && raku -I. bin/zef install . && cd .. && rm -rf zef \
    && zef install fez \
    && zef install Linenoise App::Mi6 App::Prove6 \
    && zef install JSON::Tiny Digest::HMAC Digest::SHA256::Native
    #&& apt-get purge -y --auto-remove $buildDeps

#USER jovyan

ENTRYPOINT ["/bin/bash"]
