# frozen_string_literal: true

require_relative 'easy_retry/core'
require_relative 'easy_retry/version'
require_relative 'easy_retry/configuration'

module EasyRetry
  class << self
    delegate :logger, to: :configuration

    def configuration
      @configuration ||= EasyRetry::Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
