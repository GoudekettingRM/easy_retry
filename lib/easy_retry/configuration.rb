# frozen_string_literal: true

require 'logger'

module EasyRetry
  # Configuration class
  class Configuration
    attr_accessor :logger, :delay_algorithm

    def initialize
      @logger = Logger.new($stdout)
      @delay_algorithm = :default
    end
  end
end
