# Xoxoday Plum Ruby Client

A simple client for [https://www.xoxoday.com/plum][Xoxoday Plum] B2B Synchronous API (Document Version 1.7).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'plum-ruby-client'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install plum-ruby-client
```

## Usage

Simple example for ordering a Digital Card
```ruby
# a simple client
client = Wegift::Client.new(
      :api_host => 'https://playground.plum.io',
      :api_path => '/api/b2b-sync/v1',
      :api_key => ENV['AUTH_NAME'],
      :api_secret => ENV['AUTH_PASS'],
      :proxy => ENV['PROXY']
)

# with all available products
get_products = client.products

if get_products.is_successful?
  # it provides a list of all vouchers
  vouchers = products.all
else
  # get_products.status => 403
  # get_products.error_details => "Forbidden"
end

# or just a single one
product = client.products('PROD-ID')

# and data
product.description
product.redeem_instructions_html
product.e_code_usage_type
# ... etc

# post a simple order
order = client.order(
        :product_code => product.code,
        :currency_code => 'USD',
        :amount => '42.00',
        :delivery_method => 'direct', # default
        :delivery_format => 'raw', # default
        :external_ref => '123' # optional
)

# which returns
if order.is_successful?

  # some nice data
  order.code
  order.order_id
  order.pin
  order.barcode_format
  order.barcode_string
  order.expiry_date
  order.delivery_url

end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Testing

Run it!
```bash
rspec
```

It will load all tapes found in `spec/tapes`, we are using [VCR][vcr].

To remaster all recordings, you will need a playground account.
Add an `.env` file to your root:

```bash
# .env
AUTH_NAME='playground_username'
AUTH_PASS='playground_password'
PROXY='proxy_uri'
```

Start the VCR with `rspec` - this should add all Tapes to `spec/tapes`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kendrikat/plum-ruby-client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[plum]: https://www.xoxoday.com/plum
[vcr]: https://github.com/vcr/vcr
