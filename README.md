# Webflow [![Build Status](https://github.com/weg-li/weg-li/workflows/build/badge.svg)](https://github.com/weg-li/weg-li/workflows/build/)

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'webflow-ruby'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install webflow-ruby
```

## Usage
Have a look at the tests, seriously!

### Quick Start
```ruby
client = Webflow::Client.new(WEBFLOW_API_TOKEN)
sites = client.sites
```

## Todo
* Resource mapping, it's plain hashes for now
* Proper docs (please look at the tests for now)

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/penseo/webflow-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Plugins
* [webflow_sync](https://github.com/vfonic/webflow_sync) - Keep Rails models in sync with WebFlow collections.


## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
