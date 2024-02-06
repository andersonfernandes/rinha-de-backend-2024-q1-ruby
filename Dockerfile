# Build stage
FROM ruby:3.2.3-alpine AS build

RUN mkdir -p /app
WORKDIR /app

COPY Gemfile .
COPY Gemfile.lock .

RUN gem install bundler
RUN bundle install

EXPOSE 5000

# Dev stage
FROM build AS dev

RUN apk add --update --no-cache \
  build-base \
  libpq-dev \
  tzdata

ENV RACK_ENV=development

# Prod stage
FROM build AS prod

COPY ./api /app/api
COPY ./bin /app/bin
COPY ./app.rb /app
COPY ./config.ru /app

RUN rm /app/Gemfile /app/Gemfile.lock

ENV RACK_ENV=production

CMD [ "/app/bin/server" ]