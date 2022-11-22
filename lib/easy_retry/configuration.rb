require 'logger'

module EasyRetry
  class Configuration
    attr_writer :logger

    def initialize
      @logger = Logger.new(STDOUT)
    end

    def logger
      @logger = Logger.new(STDOUT) unless @logger.respond_to?(:info)
    end
  end
end
