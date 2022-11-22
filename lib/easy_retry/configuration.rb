# frozen_string_literal: true

require 'logger'

module EasyRetry
  # Configuration class
  class Configuration
    attr_accessor :logger

    def initialize
      @logger = Logger.new($stdout)
    end
  end
end
