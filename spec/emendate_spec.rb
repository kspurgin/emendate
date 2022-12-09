# frozen_string_literal: true

RSpec.describe Emendate do
  it 'has a version number' do
    expect(Emendate::VERSION).not_to be nil
  end

  describe '#normalize' do
    let(:result){ Emendate.normalize('foo') }
    it 'returns Success' do
      expect(result).to be_a(Dry::Monads::Success)
    end

    it 'normalizes as expected' do
      examples = {
        'c. 1882(?)'=>'circa. 1882?',
        '16th c.'=> '16th century',
        '2 B.C.'=>'2 bce'
      }
      results = examples.keys
        .map{ |str| Emendate.normalize(str).value! }
      expect(results).to eq(examples.values)
    end
  end
end
