# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::NumberUtils do
  subject(:numutils){ Class.new{ extend Emendate::NumberUtils } }
  
  describe '#valid_day?' do
    let(:result){ numutils.valid_day?(str) }
    
    context 'with not valid (i.e. 42)' do
      let(:str){ '42' }
      
      it 'returns false' do
        expect(result).to be false
      end
    end

    context 'with valid (i.e. 24)' do
      let(:str){ '24' }
      
      it 'returns true' do
        expect(result).to be true
      end
    end
  end

  describe '#valid_month?' do
    let(:result){ numutils.valid_month?(str) }
    
    context 'with not valid (i.e. 21)' do
      let(:str){ '21' }
      
      it 'returns false' do
        expect(result).to be false
      end
    end

    context 'with valid (i.e. 12)' do
      let(:str){ '12' }
      
      it 'returns true' do
        expect(result).to be true
      end
    end
  end

  describe '#valid_season?' do
    let(:result){ numutils.valid_season?(str) }
    
    context 'with not valid (i.e. 14)' do
      let(:str){ '14' }
      
      it 'returns false' do
        expect(result).to be false
      end
    end

    context 'with valid (i.e. 24)' do
      let(:str){ '24' }
      
      it 'returns true' do
        expect(result).to be true
      end
    end
  end

  describe '#valid_year?' do
    let(:result){ numutils.valid_year?(str) }
    
    context 'with not valid (i.e. 9999)' do
      let(:str){ '9999' }
      
      it 'returns false' do
        expect(result).to be false
      end
    end

    context 'with valid (i.e. 1923)' do
      let(:str){ '1923' }
      
      it 'returns true' do
        expect(result).to be true
      end
    end
  end
end
