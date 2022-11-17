# frozen_string_literal: true

require_relative "easy_retry/version"

class Numeric
  def tries(rescue_from: [StandardError])
    raise ArgumentError, 'No block given' unless block_given?

    max_retry = self
    current_try = 1
    result = nil

    loop do
      result = yield(current_try)

      break
    rescue *rescue_from => error
      if defined?(Rails)
        Rails.logger.error "Error: #{error.message} (#{current_try}/#{max_retry})"
      else
        puts "Error: #{error.message} (#{current_try}/#{max_retry})"
      end

      sleep current_try * current_try

      current_try += 1

      raise error if current_try > max_retry
    end

    result
  end

  alias try tries
end
