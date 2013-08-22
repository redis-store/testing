# Redis Store testing

Common [redis-store](http://redis-store.org) utilities.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'redis-store-testing'
```

And then execute:

```shell
$ bundle
```

Or install it yourself as:

```shell
$ gem install redis-store-testing
```

## Usage

```ruby
# Rakefile
require 'bundler/setup'
require 'rake'
require 'bundler/gem_tasks'
require 'redis-store/testing/tasks'
```

```shell
$ bundle exec rake
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
