# frozen_string_literal: true

require 'pry'

class TestError < StandardError; end

# rubocop:disable Metrics/BlockLength
RSpec.describe EasyRetry do
  context 'without delay for testing purposes' do
    before do
      allow(described_class).to receive(:sleep).and_return(true)
    end

    it 'has a version number' do
      expect(described_class::VERSION).not_to be nil
    end

    it 'reruns the specified number of times if the code errors' do
      counter = 0

      expect do
        2.tries do
          counter += 1
          raise TestError
        end
      end.to raise_error(TestError)

      expect(counter).to eq 2
    end

    it 'does not rerun if the code does not error' do
      counter = 0

      3.tries do
        counter += 1
      end

      expect(counter).to eq 1
    end

    it 'returns the result of the block' do
      result = 2.tries do |try|
        raise TestError if try < 2

        'result'
      end

      expect(result).to eq 'result'
    end

    it 'aliases #try to #tries' do
      counter = 0

      expect do
        2.try do
          counter += 1
          raise TestError
        end
      end.to raise_error(TestError)

      expect(counter).to eq 2
    end

    it 'rescues the specified errors' do
      counter = 0

      expect do
        3.tries(rescue_from: [TestError]) do
          counter += 1
          raise StandardError
        end
      end.to raise_error(StandardError)

      expect(counter).to eq 1
    end

    it 'rescues the specified errors, retries, and reraises the error if it keeps failing' do
      counter = 0

      expect do
        2.tries(rescue_from: [TestError]) do
          counter += 1
          raise TestError
        end
      end.to raise_error(TestError)

      expect(counter).to eq 2
    end

    it 'raises an argument error if no block is given' do
      expect { 3.tries }.to raise_error(ArgumentError)
    end

    context 'when passing in a single error' do
      it 'behaves the same as passing in an array' do
        counter = 0

        expect do
          2.tries(rescue_from: TestError) do
            counter += 1
            raise TestError
          end
        end.to raise_error(TestError)

        expect(counter).to eq 2
      end
    end

    it 'is possible to provide config options' do
      described_class.configure do |c|
        expect(c).to eq(described_class.configuration)
      end
    end

    context 'logging' do
      context 'using the default logger' do
        it 'logs the error' do
          expect_any_instance_of(Logger).to receive(:info).with(
            'StandardError (Try Number 1/2)'
          ).exactly(:once)
          expect_any_instance_of(Logger).to receive(:info).with(
            'FAILED Permanently after 2 tries; StandardError'
          ).exactly(:once)

          expect do
            2.tries do
              raise StandardError
            end
          end.to raise_error(StandardError)
        end
      end

      context 'using a custom logger' do
        let(:super_custom_logger) { instance_double(Logger) }

        before do
          described_class.configuration.logger = super_custom_logger
        end

        after do
          described_class.configuration.logger = Logger.new($stdout)
        end

        it 'logs using that logger' do
          expect(super_custom_logger).to receive(:info).with('TestError (Try Number 1/2)').exactly(:once)
          expect(super_custom_logger).to receive(:info).with('FAILED Permanently after 2 tries; TestError').exactly(:once)

          expect do
            2.tries(rescue_from: [TestError]) do
              raise TestError
            end
          end.to raise_error(TestError)
        end
      end
    end
  end

  describe 'delay algorithm' do
    context 'when setting it on call' do
      context ':none' do
        it 'uses the algorithm that belongs to that sym' do
          expect(described_class).not_to receive(:sleep)

          expect do
            10.tries(delay: :none) do
              raise StandardError
            end
          end.to raise_error(StandardError)
        end
      end

      context ':by_try' do
        it 'sleeps for the current try' do
          expect(described_class).to receive(:sleep).with(1).exactly(:once).and_return(true)
          expect(described_class).to receive(:sleep).with(2).exactly(:once).and_return(true)
          expect(described_class).to receive(:sleep).with(3).exactly(:once).and_return(true)
          expect(described_class).to receive(:sleep).with(4).exactly(:once).and_return(true)
          expect(described_class).to receive(:sleep).with(5).exactly(:once).and_return(true)
          expect(described_class).to receive(:sleep).with(6).exactly(:once).and_return(true)
          expect(described_class).to receive(:sleep).with(7).exactly(:once).and_return(true)
          expect(described_class).to receive(:sleep).with(8).exactly(:once).and_return(true)
          expect(described_class).to receive(:sleep).with(9).exactly(:once).and_return(true)

          expect do
            10.tries(delay: :by_try) do
              raise StandardError
            end
          end.to raise_error(StandardError)
        end
      end

      context ':default' do
        it 'sleeps for the current try squared' do
          expect(described_class).to receive(:sleep).with(1).exactly(:once).and_return(true)
          expect(described_class).to receive(:sleep).with(4).exactly(:once).and_return(true)
          expect(described_class).to receive(:sleep).with(9).exactly(:once).and_return(true)
          expect(described_class).to receive(:sleep).with(16).exactly(:once).and_return(true)
          expect(described_class).to receive(:sleep).with(25).exactly(:once).and_return(true)
          expect(described_class).to receive(:sleep).with(36).exactly(:once).and_return(true)
          expect(described_class).to receive(:sleep).with(49).exactly(:once).and_return(true)
          expect(described_class).to receive(:sleep).with(64).exactly(:once).and_return(true)
          expect(described_class).to receive(:sleep).with(81).exactly(:once).and_return(true)

          expect do
            10.tries(delay: :default) do
              raise StandardError
            end
          end.to raise_error(StandardError)
        end
      end

      context ':exponential' do
        it 'sleeps for 2 to the power of the current try' do
          expect(described_class).to receive(:sleep).with(2).exactly(:once).and_return(true)
          expect(described_class).to receive(:sleep).with(4).exactly(:once).and_return(true)
          expect(described_class).to receive(:sleep).with(8).exactly(:once).and_return(true)
          expect(described_class).to receive(:sleep).with(16).exactly(:once).and_return(true)
          expect(described_class).to receive(:sleep).with(32).exactly(:once).and_return(true)
          expect(described_class).to receive(:sleep).with(64).exactly(:once).and_return(true)
          expect(described_class).to receive(:sleep).with(128).exactly(:once).and_return(true)
          expect(described_class).to receive(:sleep).with(256).exactly(:once).and_return(true)
          expect(described_class).to receive(:sleep).with(512).exactly(:once).and_return(true)

          expect do
            10.tries(delay: :exponential) do
              raise StandardError
            end
          end.to raise_error(StandardError)
        end
      end

      context 'custom lambda' do
        it 'sleeps according to the lambda function' do
          expect(self).to receive(:sleep).with(2).exactly(:once).and_return(true)
          expect(self).to receive(:sleep).with(4).exactly(:once).and_return(true)
          expect(self).to receive(:sleep).with(6).exactly(:once).and_return(true)
          expect(self).to receive(:sleep).with(8).exactly(:once).and_return(true)
          expect(self).to receive(:sleep).with(10).exactly(:once).and_return(true)
          expect(self).to receive(:sleep).with(12).exactly(:once).and_return(true)
          expect(self).to receive(:sleep).with(14).exactly(:once).and_return(true)
          expect(self).to receive(:sleep).with(16).exactly(:once).and_return(true)
          expect(self).to receive(:sleep).with(18).exactly(:once).and_return(true)

          expect do
            10.tries(delay: ->(try) { sleep try + try }) do
              raise StandardError
            end
          end.to raise_error(StandardError)
        end
      end
    end

    context 'when setting a different default delay algorithm' do
      before do
        described_class.configuration.delay_algorithm = :none
      end

      after do
        described_class.configuration.delay_algorithm = :default
      end

      it 'uses the default set' do
        expect(described_class).not_to receive(:sleep)

        expect do
          10.tries do
            raise StandardError
          end
        end.to raise_error(StandardError)
      end

      it 'does not use the default set when a different one is passed' do
        expect(described_class).to receive(:sleep).with(2).exactly(:once).and_return(true)
        expect(described_class).to receive(:sleep).with(4).exactly(:once).and_return(true)
        expect(described_class).to receive(:sleep).with(8).exactly(:once).and_return(true)
        expect(described_class).to receive(:sleep).with(16).exactly(:once).and_return(true)
        expect(described_class).to receive(:sleep).with(32).exactly(:once).and_return(true)
        expect(described_class).to receive(:sleep).with(64).exactly(:once).and_return(true)
        expect(described_class).to receive(:sleep).with(128).exactly(:once).and_return(true)
        expect(described_class).to receive(:sleep).with(256).exactly(:once).and_return(true)
        expect(described_class).to receive(:sleep).with(512).exactly(:once).and_return(true)

        expect do
          10.tries(delay: :exponential) do
            raise StandardError
          end
        end.to raise_error(StandardError)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
