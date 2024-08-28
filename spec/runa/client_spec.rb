# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Runa do
  it 'has a version number' do
    expect(Runa::VERSION).not_to be nil
  end

  it 'should provide a setup' do
    client = Runa::Client.new({
                                  api_host: 'http://dev.example.com',
                                  api_key: 'abc',
                                  api_secret: '123'
                                })

    expect(client.class).to eq Runa::Client
    expect(client.api_secret).to eq '123'
    expect(client.api_key).to eq 'abc'
    expect(client.api_host).to eq 'http://dev.example.com'
  end

  it 'should provide a default setup' do
    client = Runa::Client.new

    expect(client.api_host).to eq 'https://playground.runa.io'
    expect(client.api_path).to eq '/api/b2b-sync/v1'
  end
end
