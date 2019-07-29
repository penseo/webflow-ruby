# Webflow [![Build Status](https://travis-ci.org/penseo/webflow-ruby.svg?branch=master)](https://travis-ci.org/penseo/webflow-ruby)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'webflow-ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install webflow-ruby

## Usage

Have a look at the tests, seriously!

### Quick Start
```ruby
    client = Webflow::Client.new(WEBFLOW_API_TOKEN)
    sites = client.sites
```

## Todo

* Error handling, it's all JSON for now
* Resource mapping, it's plain hashes for now
* Proper docs

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/penseo/webflow-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
