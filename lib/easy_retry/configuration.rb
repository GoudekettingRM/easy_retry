require 'logger'

module EasyRetry
  class Configuration
    attr_writer :logger

    def initialize
      @logger = Logger.new(STDOUT)
    end
  end
end
