# frozen_string_literal: true

class Runa::Product < Runa::Response
  PATH = '/product'

  # request/payload
  attr_accessor :product_code

  # response/success
  attr_accessor :code, :name, :description, :currency, :availability,
                :countries_redeemable_in,
                :categories,
                :state,
                :gift_card,
                :subscription

  def initialize(params = {})
    super
  end

  def path
    [PATH, @product_code.to_s].join('/')
  end

  # Product Details List
  # GET /v2/product/ID
  def get(ctx)
    response = ctx.request(:get, path, {}, '')
    parse(response)
  end

  def parse(response)
    super(response)

    Runa::Product.new(@payload)
  end
end
