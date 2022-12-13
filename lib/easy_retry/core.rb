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
      message = e.message == e.class.name ? ' ' : ": #{e.message} "

      if current_try >= max_retry
        EasyRetry.logger.info "FAILED Permanently after #{max_retry} tries; #{e.class.name}#{message}".strip
        raise
      else
        EasyRetry.logger.info "#{e.class.name}#{message}(Try Number #{current_try}/#{max_retry})"
      end

      if delay.is_a?(Proc)
        delay.call(current_try)
      else
        EasyRetry.delay_options[delay].call(current_try)
      end

      current_try += 1
    end

    result
  end
  # rubocop:enable Metrics/MethodLength

  alias try tries
end
