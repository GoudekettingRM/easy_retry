![Specs](https://github.com/goudekettingrm/easy_retry/actions/workflows/main.yml/badge.svg)

<a href="https://www.buymeacoffee.com/goudekettingrm" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-blue.png" alt="Buy Me A Coffee" height="41" width="174"></a>

# EasyRetry

<i>Easily retry a block of code a predetermined number of times.</i>

Easy Retry adds a #tries method to the Numeric class. The #tries method takes a block of code and will retry the block a number of times equal to the number the method is called on. It also aliases #try to #tries in the odd case that you want to (~re~?)try a block of code only once.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'easy_retry'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install easy_retry

## Usage

If you're not using Bundler, you'll need to require the gem in your code:
```rb
  require 'easy_retry'
```

### Basic Example

```rb
  4.tries do |try|
    raise 'Something went wrong' if try < 4
    puts "Success!"
  end
```

The code above will produce the following output:

```
  Error: Something went wrong (1/4)
  Error: Something went wrong (2/4)
  Error: Something went wrong (3/4)
  Success!
```

## Only Retry on Certain Exceptions

Sometimes you want to only retry your code if a specific exception is raised. You can do this by passing a list of exceptions to the #tries method:

```rb
  4.tries(rescue_from: [ZeroDivisionError, ArgumentError]) do |try|
    raise ZeroDivisionError if try < 2
    raise ActiveRecord::RecordInvalid if try < 4
    puts "Success!"
  end
```

The code above will not rescue from the `ActiveRecord::RecordInvalid` error and produce the following output:

```
  Error: ZeroDivisionError (1/4)
  ActiveRecord::RecordInvalid: Record invalid
  from (pry):16:in `block in __pry__'
```

Passing an array is not necessary if you need to only rescue from a single error

```rb
  4.tries(rescue_from: ZeroDivisionError) do |try|
    raise ZeroDivisionError if try < 2
    raise ActiveRecord::RecordInvalid if try < 4
    puts "Success!"
  end
```

This will generate the same output.

## Block results

EasyRetry gives you back the result of the first time the block you passed successfully runs. This can be useful when you need to use the result of the block for other tasks that you do not necessarily want to place in the block.

```rb
  result = 2.tries do |try|
    raise 'Woops' if try < 2
    "This is try number #{try}"
  end

  puts result
```

The code above will produce the following output.

```
  Error: Woops (1/2)
  => "This is try number 2"
```

## Configuration

You can configure EasyRetry by adding an initializer as follows:

```rb
  EasyRetry.configure do |config|
    # configuration options
  end
```

### Logger

By default, EasyRetry uses [logger](https://rubygems.org/gems/logger) for logging errors. You can add your custom logger in the configuration using the `config.logger` option.

```rb
  # For Example, using Rails.logger
  config.logger = Rails.logger
```

NB: The logger should follow Rails Logger conventions.

## Retry delay

The delay for each retry is based on the iteration count. The delay after each failed attempt is _n^2_, where _n_ is the current iteration that failed. E.g. after the first try, EasyRetry waits 1 second, after the second try it waits 4 seconds, then 9, then 16, then 25, then 36, etc.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/GoudekettingRM/easy_retry. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/GoudekettingRM/easy_retry/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the EasyRetry project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/GoudekettingRM/easy_retry/blob/main/CODE_OF_CONDUCT.md).
