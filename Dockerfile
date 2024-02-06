FROM ruby:3.2.3-alpine

RUN apk add --update --no-cache \
  bash \
  build-base \
  sudo \
  libpq-dev \
  tzdata

RUN mkdir -p /app
WORKDIR /app

COPY . .

RUN gem install bundler
RUN bundle install