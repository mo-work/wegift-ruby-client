# frozen_string_literal: true

class Runa::Products < Runa::Response
  PATH = '/product'

  attr_accessor :all

  # Product Details List
  # GET /v2/product
  def get(ctx)
    @all = []
    @after_key = nil

    loop do
      path = @after_key.nil? ? "#{PATH}" : "#{PATH}?after=#{@after_key}"
      response = ctx.request(:get, path, {}, '')
      parse(response)
      if @after_key.nil?
        break
      end
    end

    self
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
          @all.concat(@payload['catalog'].map { |p| Runa::Product.new(p) })
      end
      @after_key = @payload['pagination']['cursors']['after']
    else
      @all = []
    end
  end
end
