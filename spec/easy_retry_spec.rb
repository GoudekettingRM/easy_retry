# frozen_string_literal: true

class TestError < StandardError; end

# rubocop:disable Metrics/BlockLength
RSpec.describe EasyRetry do
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

  it 'sleeps for the current try squared' do
    expected_diff = 1 + 4 + 9
    start_time = Time.now.to_i

    expect do
      4.tries do
        raise StandardError
      end
    end.to raise_error(StandardError)

    end_time = Time.now.to_i

    expect(end_time - start_time).to be_within(1).of(expected_diff)
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
        expect_any_instance_of(Logger).to receive(:info).with('StandardError: StandardError (1/1)')

        expect do
          1.tries do
            raise StandardError
          end
        end.to raise_error(StandardError)
      end
    end

    context 'using a custom logger' do
      let(:super_custom_logger) { instance_double(Logger) }

      before do
        described_class.configure do |config|
          config.logger = super_custom_logger
        end
      end

      it 'logs using that logger' do
        expect(super_custom_logger).to receive(:info).with('TestError: TestError (1/1)')

        expect do
          1.try(rescue_from: [TestError]) do
            raise TestError
          end
        end.to raise_error(TestError)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
