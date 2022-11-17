# frozen_string_literal: true

require_relative "easy_retry/version"

# Extend the Numeric class with a #tries method
class Numeric
  # rubocop:disable Metrics/MethodLength
  def tries(rescue_from: [StandardError])
    raise ArgumentError, "No block given" unless block_given?

    max_retry = self
    current_try = 1
    result = nil

    loop do
      result = yield(current_try)

      break
    rescue *rescue_from => e
      if defined?(Rails)
        Rails.logger.error "Error: #{e.message} (#{current_try}/#{max_retry})"
      else
        puts "Error: #{e.message} (#{current_try}/#{max_retry})"
      end

      sleep current_try * current_try

      current_try += 1

      raise e if current_try > max_retry
    end

    result
  end
  # rubocop:enable Metrics/MethodLength

  alias try tries
end
