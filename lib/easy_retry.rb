# frozen_string_literal: true

require_relative "easy_retry/version"

class Numeric
  def tries(rescue_from: [StandardError])
    raise ArgumentError, 'No block given' unless block_given?

    max_retry = self
    current_try = 1

    loop do
      yield(current_try)

      break
    rescue *rescue_from => error
      Rails.logger.error "Error: #{error.message} (#{current_try}/#{max_retry})"

      sleep (current_try * current_try).seconds

      current_try += 1

      raise error if current_try > max_retry
    end
  end

  alias try tries
end
