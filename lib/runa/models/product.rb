# frozen_string_literal: true

class Runa::Product < Runa::Response
  PATH = '/product'

  # request/payload
  attr_accessor :product_code

  # response/success
  attr_accessor :available_denominations,
                :availability,
                :card_image_url,
                :categories,
                :code,
                :content_resources,
                :countries_redeemable_in,
                :currency,
                :denomination_type,
                :description_url,
                :e_code_usage_type,
                :gift_card,
                :name,
                :minimum_value,
                :maximum_value,
                :redeem_instructions_url,
                :state,
                :nonsense,
                :terms_and_conditions_url

  def initialize(params = {})
    super

    unless gift_card.nil?
      denominations = gift_card['denominations']
      @denomination_type = denominations['type']
      @available_denominations = denominations['available_list']
      @minimum_value = denominations['minimum_value']
      @maximum_value = denominations['maximum_value']
      @card_image_url = gift_card['assets']['card_image_url']
      @e_code_usage_type = gift_card['e_code_usage_type']

      @content_resources = gift_card['content_resources']
      @description_url = @content_resources['description_markdown_url']
      @redeem_instructions_url = @content_resources['redemption_instructions_markdown_url']
      @terms_and_conditions_url = @content_resources['terms_consumer_markdown_url']
    end

    self
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
