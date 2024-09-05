# frozen_string_literal: true

class Runa::Order < Runa::Response
  PATH = '/order'

  DELIVERY_METHODS = { direct: 'direct', email: 'email' }.freeze
  DELIVERY_FORMATS = { code: 'raw', url: 'url-instant' }.freeze

  # request/payload
  attr_accessor :payment_type, :currency, :face_value, :distribution_type, :product_code
  
  # response/success
  attr_accessor :code, :id, :status, :created_at, :payment_method, :currency, :total_price,   
                :total_discount, :items, :redemption_url, :order_id

  def initialize(params = {})
    super(params)
    # default/fallback: 'direct'/'raw'
    @delivery_method = params[:delivery_method] || DELIVERY_METHODS[:direct]
    @delivery_format = params[:delivery_format] || DELIVERY_FORMATS[:code]
  end

  def payload
    {
      payment_method: {
        type: @payment_type,
        currency: @currency
      },
      items: [
        {
          face_value: @face_value,
          distribution_method: {
            type: @distribution_type
          },
          products: {
              type: "SINGLE",
              value: @product_code
          }
        }
      ],
    }
  end

  # Create a new order
  # POST /v2/order
  def post(ctx)
    response = ctx.request(:post, PATH, payload)
    parse(response)
  end

  def parse(response)
    super(response)

    if @payload['status'].eql?(STATUS[:failed])
      @status = @payload['status']
      unless @payload['type'].blank?
        @type = @payload['type']
      end
      unless @payload['message'].blank?
        @message = @payload['message']
      end
      unless @payload['help'].blank?
        @help = @payload['help']
      end
    end

    # set valid data
    if @payload['status'] && @payload['status'].eql?(STATUS[:completed])
      @status = @payload['status']
      @total_price = @payload['total_price']
      @items = @payload['items']
    end

    @order_id = @payload['id']

    self
  end
end
