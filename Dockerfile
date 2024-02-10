# Build stage
FROM ruby:3.2.3-alpine AS build

RUN mkdir -p /app
WORKDIR /app

RUN apk add --update --no-cache \
  build-base \
  libpq-dev \
  tzdata

COPY Gemfile .
COPY Gemfile.lock .

RUN gem install bundler
RUN bundle install --verbose

EXPOSE 5000

# Prod stage
FROM build AS prod

COPY ./bin /app/bin
COPY ./config /app/config
COPY ./lib /app/lib
COPY ./app.rb /app

ENV RACK_ENV=production

CMD [ "/app/bin/server" ]