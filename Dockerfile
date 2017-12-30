FROM ruby:2.5-slim
MAINTAINER Arnau Siches <asiches@gmail.com>

RUN mkdir -p /usr/src/iso8601
WORKDIR /usr/src/iso8601

COPY . /usr/src/iso8601
RUN bundle install

CMD ["bundle", "exec", "rspec"]
