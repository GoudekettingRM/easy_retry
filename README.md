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

## Retry delay

The delay for each retry is based on the iteration count. The delay after each failed attempt is _n^2_, where _n_ is the current iteration that failed. E.g. after the first try, EasyRetry waits 1 second, after the second try it waits 4 seconds, then 9, then 16, then 25, then 36, etc.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/easy_retry. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/easy_retry/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the EasyRetry project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/easy_retry/blob/main/CODE_OF_CONDUCT.md).
