# frozen_string_literal: true

class TestError < StandardError; end

# rubocop:disable Metrics/BlockLength
RSpec.describe EasyRetry do
  it 'has a version number' do
    expect(EasyRetry::VERSION).not_to be nil
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

  it 'puts the error' do
    expect($stdout).to receive(:puts).with('Error: StandardError (1/1)')

    expect do
      1.tries do
        raise StandardError
      end
    end.to raise_error(StandardError)
  end

  context 'when used in a rails app' do
    let(:logger) { double }

    # rubocop:disable Lint/ConstantDefinitionInBlock
    before do
      Rails = double
      allow(Rails).to receive(:logger).and_return(logger)
      allow(logger).to receive(:error)
    end
    # rubocop:enable Lint/ConstantDefinitionInBlock

    it 'logs using the rails logger' do
      expect(logger).to receive(:error).with('Error: TestError (1/1)')

      expect do
        1.try(rescue_from: [TestError]) do
          raise TestError
        end
      end.to raise_error(TestError)
    end
  end
end
# rubocop:enable Metrics/BlockLength
