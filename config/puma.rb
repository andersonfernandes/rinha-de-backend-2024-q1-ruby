#!/usr/bin/env puma
# frozen_string_literal: true

threads_count = ENV.fetch('PUMA_THREADS') { 5 }.to_i
threads threads_count, threads_count

port ENV.fetch('PORT') { 5000 }
workers ENV.fetch('WORKERS') { 0 }.to_i