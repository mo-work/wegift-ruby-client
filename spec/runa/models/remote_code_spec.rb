# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Runa::RemoteCode do
  describe 'GET' do
    let(:url) { 'https://connect.playground.runa.io/public/gifts/instant/db38667b-055e-446e-ac0f-bbf4b9227a95' }
    let(:remote_code) { client.remote_code(url) }
    let(:client) { set_runa_client }

    context 'when URL is invalid' do
      let(:url) { 'https://thisnotworking.yo' }

      it 'raises error' do
        VCR.use_cassette('get_remote_code_invalid_url_does_not_exist') do
          expect { remote_code }.to raise_error(Faraday::ConnectionFailed)
        end
      end
    end


    it 'is successful' do
      VCR.use_cassette('get_remote_code_valid') do
        expect(remote_code.is_successful?).to be_truthy
      end
    end

    it 'returns the amount' do
      VCR.use_cassette('get_remote_code_valid') do
        expect(remote_code.amount).to eq('0.01')
      end
    end

    it 'returns the barcode format' do
      VCR.use_cassette('get_remote_code_valid') do
        expect(remote_code.barcode_format).to eq('code-128')
      end
    end

    it 'returns the barcode string' do
      VCR.use_cassette('get_remote_code_valid') do
        expect(remote_code.barcode_string).to eq('2553847550730045')
      end
    end

    it 'returns the code' do
      VCR.use_cassette('get_remote_code_valid') do
        expect(remote_code.code).to eq('2553847550730045')
      end
    end

    it 'returns the expiry date' do
      VCR.use_cassette('get_remote_code_valid') do
        expect(remote_code.expiry_date).to eq('2027-09-05')
      end
    end

    it 'returns the pin' do
      VCR.use_cassette('get_remote_code_valid') do
        expect(remote_code.pin).to eq('082145')
      end
    end

    it 'returns the type' do
      VCR.use_cassette('get_remote_code_valid') do
        expect(remote_code.type).to eq('code')
      end
    end
  end
end
