# frozen_string_literal: true

# Extend the Numeric class with a #tries method
class Numeric
  # rubocop:disable Metrics/MethodLength
  def tries(rescue_from: [StandardError], delay: EasyRetry.delay_algorithm)
    raise ArgumentError, 'No block given' unless block_given?

    rescue_from = Array(rescue_from)
    max_retry = self
    current_try = 1
    result = nil

    loop do
      result = yield(current_try)

      break
    rescue *rescue_from => e
      log_failed_try(e, current_try, max_retry)

      call_delay(delay, current_try)

      current_try += 1
    end

    result
  end
  # rubocop:enable Metrics/MethodLength

  alias try tries

  private

  def call_delay(delay, current_try)
    return delay.call(current_try) if delay.is_a?(Proc)

    EasyRetry.delay_options[delay].call(current_try)
  end

  def log_failed_try(error, current_try, max_retry)
    message = error.message == error.class.name ? ' ' : ": #{error.message} "

    if current_try >= max_retry
      EasyRetry.logger.info "FAILED Permanently after #{max_retry} tries; #{error.class.name}#{message}".strip
      raise
    else
      EasyRetry.logger.info "#{error.class.name}#{message}(Try Number #{current_try}/#{max_retry})"
    end
  end
end
