FROM rubinius/docker
MAINTAINER Arnau Siches <asiches@gmail.com>

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

WORKDIR /usr/src/iso8601

COPY . /usr/src/iso8601
RUN bundle install

CMD ["bundle", "exec", "rspec"]
