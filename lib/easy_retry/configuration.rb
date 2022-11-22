require 'logger'

module EasyRetry
  class Configuration
    attr_accessor :logger

    def initialize
      @logger = Logger.new(STDOUT)
    end
  end
end
