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
  end
end
