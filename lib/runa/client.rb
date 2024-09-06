# frozen_string_literal: true

require 'faraday'
require 'securerandom'

require_relative 'models/response'
require_relative 'models/product'
require_relative 'models/products'
require_relative 'models/order'
require_relative 'models/remote_code'

module Runa
  class Client
    attr_accessor :api_host, :api_path, :api_key, :api_secret, :connection

    # supported: basic-http-auth - see: https://playground.runa.io

    def initialize(options = {})
      @api_host = options[:api_host] || 'https://playground.runa.io'
      @api_path = options[:api_path] || '/v2'
      @api_key = options[:api_key].to_s

      @connection = Faraday.new(url: @api_host) do |c|
        c.adapter Faraday.default_adapter
        unless options[:proxy].nil?
          c.options[:proxy] = {
            uri: URI(options[:proxy])
          }
        end
      end
    end

    def request(method, path, payload = {}, key)
      @connection.send(method) do |req|
        req.url [@api_path, path].join
        req.headers['Content-Type'] = 'application/json'.freeze
        req.headers['X-Api-Key'] = @api_key
        req.headers['X-Api-Version'] = '2024-02-05'.freeze
        req.headers['X-Execution-Mode'] = 'sync'.freeze
        if method.eql? :post
          req.headers['X-Idempotency-Key'] = key unless key.empty?
        end
        req.body = payload.to_json if method.to_sym.eql?(:post)
        req.params = payload if method.to_sym.eql?(:get)
      end
    end

    # TODO: shared context/connection for all calls
    # keep client => https://github.com/lostisland/faraday#basic-use

    # global methods

    def products
      products = Runa::Products.new
      products.get(self)
    end

    def product(id = nil)
      products = Runa::Product.new(product_code: id)
      products.get(self)
    end

    def order(options)
      order = Runa::Order.new(options)
      order.post(self)
    end

    def remote_code(url)
      code = Runa::RemoteCode.new(url: url)
      code.get(self)
    end
  end
end
