# frozen_string_literal: true

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

# Extend the Numeric class with a #tries method
class Numeric
  # rubocop:disable Metrics/MethodLength
  def tries(rescue_from: [StandardError])
    raise ArgumentError, 'No block given' unless block_given?

    rescue_from = Array(rescue_from)
    max_retry = self
    current_try = 1
    result = nil

    loop do
      result = yield(current_try)

      break
    rescue *rescue_from => e
      EasyRetry.logger.info "Error: #{e.message} (#{current_try}/#{max_retry})"

      raise if current_try >= max_retry

      sleep current_try * current_try

      current_try += 1
    end

    result
  end
  # rubocop:enable Metrics/MethodLength

  alias try tries
end
