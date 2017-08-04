# Seed::Snapshot

[![Build Status](https://travis-ci.org/waka/seed-snapshot.png?branch=master)](https://travis-ci.org/waka/seed-snapshot)

This library manage of dump/restore data by database.

## Installation

Add this line to your application's Gemfile:

```ruby
group :test do
  gem 'seed-snapshot'
end
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install seed-snapshot

## Usage

Auto configuration Seed::Snapshot itself.

```
Seed::Snapshot.configure do |config|
  config.tables = [User, Item]

  config.restore_hook = :before_suite
  config.dump_hook    = :after_suite
end
```

Manual configuration in RSpec with DatabaseCleaner (optional).

```
RSpec.configure do |config|
  tables = [User, Item]

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction

    if Seed::Snapshot.exists?
      Seed::Snapshot.restore(tables)
    else
      # load seed data normally
    end
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:suite) do
    if Seed::Snapshot.exists?
      Seed::Snapshot.dump(tables)
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/waka/seed-snapshot.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

