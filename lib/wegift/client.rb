# encoding: utf-8
require 'faraday'

require_relative 'models/response'
require_relative 'models/product'
require_relative 'models/products'
require_relative 'models/order'

module Wegift

  class Client
    attr_accessor :api_host, :api_path, :api_key, :api_secret, :connection

    # supported: basic-http-auth - see: http://sandbox.wegift.io

    def initialize(options = {})
      @api_host = options[:api_host] || 'https://api-sandbox.wegift.io'
      @api_path = options[:api_path] || '/api/b2b-sync/v1'
      @api_key = options[:api_key].to_s
      @api_secret = options[:api_secret]

      @connection = Faraday.new(:url => @api_host) do |c|
        c.basic_auth(@api_key, @api_secret)
        c.adapter Faraday.default_adapter
        c.options[:proxy] = {
            :uri => URI(options[:proxy])
        } unless options[:proxy].nil?
      end
    end

    def request(method, path, payload = {})
      @connection.send(method) do |req|
        req.url [@api_path, path].join('')
        req.headers['Content-Type'] = 'application/json'
        req.body = payload.to_json if method.to_sym.eql?(:post)
        req.params = payload if method.to_sym.eql?(:get)
      end
    end

    # TODO: shared context/connection for all calls
    # keep client => https://github.com/lostisland/faraday#basic-use

    # global methods

    def products()
      # initialize endpoint
      products = Wegift::Products.new()

      # get catalogue with context / current connection
      products.get(self)

      # TODO: shared error handling
    end

    def product(id = nil)
      products = Wegift::Product.new(:product_code => id)
      products.get(self)
    end

    def order(options)
      order = Wegift::Order.new(options)
      order.post(self)
    end

  end

end
