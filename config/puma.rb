#!/usr/bin/env puma
# frozen_string_literal: true

require "./config/database"

threads_count = ENV.fetch("PUMA_THREADS") { 5 }.to_i
threads threads_count, threads_count

port ENV.fetch("PORT") { 5000 }
workers ENV.fetch("WORKERS") { 1 }.to_i

on_worker_boot do
  Database.init!
end
