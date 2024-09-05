# frozen_string_literal: true

class Runa::Products < Runa::Response
  PATH = '/product'

  attr_accessor :all

  # Product Details List
  # GET /v2/product
  def get(ctx)
    response = ctx.request(:get, PATH)
    parse(response)
  end

  # Find all products by fieldname.
  def find(name, value)
    Runa::Products.new(all: all.select! { |p| p.send(name).eql?(value) })
  end

  def parse(response)
    super(response)

    if is_successful?
      # TODO: separate?
      if @payload['catalog']
        @all = @payload['catalog'].map { |p| Runa::Product.new(p) }
      end
    else
      @all = []
    end

    self
  end
end
