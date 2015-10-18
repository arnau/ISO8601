FROM debian:wheezy
MAINTAINER Arnau Siches <asiches@gmail.com>

ENV RBX_VERSION 2.5.8
ENV HOME /root

RUN apt-get update -qqy \
 && apt-get install -qqy \
       bison \
       build-essential \
       curl \
       libedit-dev \
       libeditline-dev \
       libncurses5-dev \
       libreadline-dev \
       libssl-dev \
       libyaml-dev \
       llvm \
       llvm-dev \
       locales \
       rake \
       ruby-dev \
       zlib1g-dev \
 && gem install bundler \
 && rm -rf /var/lib/apt/lists/* \
 && locale-gen en_US.UTF-8 \
 && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN curl -L -O https://github.com/rubinius/rubinius/releases/download/v$RBX_VERSION/rubinius-$RBX_VERSION.tar.bz2 \
 && tar xvfj rubinius-$RBX_VERSION.tar.bz2

WORKDIR /rubinius-$RBX_VERSION

RUN bundle install \
 && ./configure --prefix=/usr/local/rubinius \
 && rake install \
 && ln -sf /usr/local/rubinius/bin/ruby /usr/bin/ruby \
 && ln -sf /usr/local/rubinius/bin/gem /usr/bin/gem \
 && ln -sf /usr/local/rubinius/bin/rake /usr/bin/rake \
 && gem install bundler

ENV PATH $PATH:/usr/local/rubinius/bin

RUN mkdir -p /usr/src/iso8601
WORKDIR /usr/src/iso8601

COPY . /usr/src/iso8601
RUN bundle install

CMD ["bundle", "exec", "rspec"]
