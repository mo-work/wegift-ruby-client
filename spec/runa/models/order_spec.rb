# frozen_string_literal: true

require 'spec_helper'
require 'securerandom'

RSpec.describe Runa::Order do
  def set_order(payment_type, currency, face_value, distribution_type, product_code, external_ref)
    Runa::Order.new(
      payment_type: payment_type,
      currency: currency,
      face_value: face_value,
      distribution_type: distribution_type,
      product_code: product_code,
      external_ref: external_ref
    )
  end

  let(:client) { set_runa_client }

  it 'should set payload' do
    order = set_order('1', '2', '3', '4', '5', '6')

    expect(order.payment_type).to eq('1')
    expect(order.currency).to eq('2')
    expect(order.face_value).to eq('3')
    expect(order.distribution_type).to eq('4')
    expect(order.product_code).to eq('5')
  end

  describe 'POST' do
    it 'should return error (401)' do
      client = set_runa_client_unauthed
      order = set_order(
        '1',
        '2',
        '3',
        '4',
        '5',
        '6'
      )

      VCR.use_cassette('post_order_invalid_401') do
        order.post(client)

        expect(order.class).to eq(Runa::Order)
        expect(order.is_successful?).to eq(false)
        expect(order.status).to eq(Runa::Response::STATUS[:failed])
        expect(order.error_string).to eq('Unauthorized')
        expect(order.order_id).to eq(nil)
      end
    end
    
    it 'should return error (403)' do
      client = set_runa_client_bad_auth
      order = set_order(
        '1',
        '2',
        '3',
        '4',
        '5',
        '6'
      )

      VCR.use_cassette('post_order_invalid_403') do
        order.post(client)

        expect(order.class).to eq(Runa::Order)
        expect(order.is_successful?).to eq(false)
        expect(order.status).to eq(Runa::Response::STATUS[:failed])
        expect(order.error_string).to eq("Forbidden")
        expect(order.order_id).to eq(nil)
      end
    end

    it 'should create an url' do
      client = set_runa_client

      VCR.use_cassette('get_product_catalogue_valid') do
        product = client.products.all[1]

        VCR.use_cassette('post_order_for_url_valid') do
          order = client.order(
            payment_type: 'ACCOUNT_BALANCE',
            currency: 'USD',
            face_value: 10,
            distribution_type: 'PAYOUT_LINK',
            product_code: '1800FL-US',
            external_ref: SecureRandom.uuid
          )

          expect(order.class).to eq(Runa::Order)
          expect(order.is_successful?).to eq(true)
          expect(order.status).to eq(Runa::Response::STATUS[:completed])
          expect(order.error_string).to eq(nil)
          expect(order.total_price).to eq("10.00")
          expect(order.order_id).not_to eq(nil)
        end
      end
    end

    # TODO: more checks/cases
  end
end
