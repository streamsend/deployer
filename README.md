# Deployer

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'deployer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install deployer

## Usage

### Basic Steps
1. Add token and path in config/creds.yml
2. Run `bundle install`
3. Run `get_stories.rb --previous-version v2.0.1`

### Help Docs
Pivotal Release Notes Generator

    Usage: get_stories.rb [options]
  -p, --previous-version=<s>    The last released version
  -i, --pivotal-token=<s>       The pivotal token (default: 1b8c07d8d84f1ac8261e3af4266d0d80)
  -r, --project-dir=<s>         The project directory (default: /Users/<yourpath>/projects/streamsend-root/streamsend)
  -h, --help                    Show this message

## Contributing

1. Fork it ( https://github.com/[my-github-username]/deployer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
