# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Runa::Product do
  describe 'GET' do
    describe 'all' do
      let(:code) { '1800FL-US' }
      let(:client) { set_runa_client }
      let(:product) { client.product(code) }
      let(:products) { client.products }

      context 'when unauthenticated' do
        let(:client) { set_runa_client_unauthed }

        it 'should return an error' do
          VCR.use_cassette('get_product_catalogue_invalid_401') do
            expect(products.class).to eq(Runa::Products)
            expect(products.status).to eq(Runa::Response::STATUS[:failed])
          end
        end
      end

      it 'should return a set of products' do
        VCR.use_cassette('get_product_catalogue_valid') do
          expect(products.class).to eq(Runa::Products)
          expect(products.all.is_a?(Array)).to eq(true)
          expect(products.all.first.class).to eq(Runa::Product)
          expect(products.status).to eq(Runa::Response::STATUS[:completed])
        end
      end

      it 'should return a set of paginated products' do
        VCR.use_cassette('get_product_catalogue_valid_paginated') do
          expect(products.class).to eq(Runa::Products)
          expect(products.all.is_a?(Array)).to eq(true)
          expect(products.all.first.class).to eq(Runa::Product)
          expect(products.all.length).to eq(20)
          expect(products.status).to eq(Runa::Response::STATUS[:completed])
        end
      end

      it 'should return a single product' do
        VCR.use_cassette('get_product_catalogue_valid') do
          products = client.products.all
          product_from_catalogue = products.first

          VCR.use_cassette('get_product_item_valid') do
            product = client.product(product_from_catalogue.code)

            expect(product.class).to eq(Runa::Product)
            expect(product.code).to eq(product_from_catalogue.code)
          end
        end
      end

      it 'should have instructions' do
        VCR.use_cassette('get_product_item_valid') do
          expect(product.class).to eq(Runa::Product)
          expect(product.code).to eq(code)
          expect(product.gift_card['content_resources']['redemption_instructions_markdown_url']).not_to eq(nil)
        end
      end

      it 'should have usage type' do
        VCR.use_cassette('get_product_item_valid') do
          # this should exist, can be null, "url-only/url-recommended" (ARGOS-GB / DECA-BE)
          expect(product.gift_card['e_code_usage_type']).to eq('url-recommended')
        end
      end

      it 'should have countries' do
        VCR.use_cassette('get_product_item_valid') do
          expect(product.countries_redeemable_in).to eq(['US'])
        end
      end

      it 'should have categories' do
        VCR.use_cassette('get_product_item_valid') do
          expect(product.categories).to include('department-stores')
        end
      end

      it 'should have a state' do
        VCR.use_cassette('get_product_item_valid') do
          expect(product.state).to eq('LIVE')
        end
      end

      context 'realtime availability' do
        context 'fixed denomination type' do
          let(:code) { 'ABBON-IT' }

          it 'should have available denominations' do
            VCR.use_cassette('get_product_item_valid_denominations') do
              expect(product.gift_card['denominations']['type']).to eq('fixed')
              expect(product.gift_card['denominations']['available_list']).to match_array(['20', '25', '30'])
            end
          end
        end

        context 'open denomination type' do
          it 'should not have available denominations' do
            VCR.use_cassette('get_product_item_valid') do
              expect(product.gift_card['denominations']['type']).to eq('open')
            end
          end
        end
      end
    end
  end
end
