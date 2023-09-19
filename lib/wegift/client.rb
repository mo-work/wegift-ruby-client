# frozen_string_literal: true

require 'faraday'

require_relative 'models/response'
require_relative 'models/product'
require_relative 'models/products'
require_relative 'models/order'
require_relative 'models/stock'
require_relative 'models/remote_code'

module Wegift
  class Client
    attr_accessor :api_host, :api_path, :api_key, :api_secret, :connection

    # supported: basic-http-auth - see: https://playground.wegift.io

    def initialize(options = {})
      @api_host = options[:api_host] || 'https://playground.wegift.io'
      @api_path = options[:api_path] || '/api/b2b-sync/v1'
      @api_key = options[:api_key].to_s
      @api_secret = options[:api_secret]

      faraday_options = { url: @api_host }
      unless options[:proxy].nil?
        faraday_options[:proxy] = {
          uri: URI(options[:proxy])
        }
      end

      @connection = Faraday.new(faraday_options) do |c|
        c.request(:authorization, :basic, @api_key, @api_secret)
        c.adapter Faraday.default_adapter
      end
    end

    def request(method, path, payload = {})
      @connection.send(method) do |req|
        req.url [@api_path, path].join
        req.headers['Content-Type'] = 'application/json'
        req.body = payload.to_json if method.to_sym.eql?(:post)
        req.params = payload if method.to_sym.eql?(:get)
      end
    end

    # TODO: shared context/connection for all calls
    # keep client => https://github.com/lostisland/faraday#basic-use

    # global methods

    def products
      products = Wegift::Products.new
      products.get(self)
    end

    def product(id = nil)
      products = Wegift::Product.new(product_code: id)
      products.get(self)
    end

    def order(options)
      order = Wegift::Order.new(options)
      order.post(self)
    end

    def stock(id)
      stock = Wegift::Stock.new(id: id)
      stock.get(self)
    end

    def remote_code(url)
      code = Wegift::RemoteCode.new(url: url)
      code.get(self)
    end
  end
end
