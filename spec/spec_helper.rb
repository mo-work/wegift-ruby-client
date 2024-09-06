# frozen_string_literal: true

require 'bundler/setup'
require 'byebug'
require 'dotenv/load'
require 'runa/client'
require 'webmock/rspec'
require 'vcr'

def set_runa_client
  Runa::Client.new(
    api_key: ENV['API_KEY'],
    proxy: ENV['PROXY'],
    test_mode: true
  )
end

def set_runa_client_bad_auth
  Runa::Client.new(
    api_key: 'asdfasdfasdf',
    proxy: ENV['PROXY'],
    test_mode: true
  )
end

def set_runa_client_unauthed
  Runa::Client.new(
    test_mode: true
  )
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/tapes'
  c.hook_into :webmock

  c.before_record do |i|
    i.response.headers.delete("Set-Cookie")
    i.request.headers.delete("X-Api-Key")
    i.request.headers.delete("X-Idempotency-Key")
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
