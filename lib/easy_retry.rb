# frozen_string_literal: true

require_relative 'easy_retry/core'
require_relative 'easy_retry/version'
require_relative 'easy_retry/configuration'

# EasyRetry core module
module EasyRetry
  class << self
    def configuration
      @configuration ||= EasyRetry::Configuration.new
    end

    def configure
      yield(configuration)
    end

    def logger
      configuration.logger
    end

    def delay_algorithm
      configuration.delay_algorithm
    end

    def delay_options
      {
        none: ->(_try_number) {},
        by_try: ->(try_number) { sleep try_number },
        default: ->(try_number) { sleep try_number * try_number },
        exponential: ->(try_number) { sleep 2**try_number }
      }
    end
  end
end
