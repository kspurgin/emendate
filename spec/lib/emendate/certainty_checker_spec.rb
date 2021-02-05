require 'spec_helper'

RSpec.describe Emendate::CertaintyChecker do
  def check(str, options = {})
    pm = Emendate.prep_for(str, :certainty_check_whole_values, options)
    cc = Emendate::CertaintyChecker.new(tokens: pm.tokens, options: pm.options)
    cc.check.result
  end

  describe '#check' do
    context '[circa 2002?]' do
      context 'default square bracket handling' do
        before(:all) do
          @c = check('[circa 2002?]')
        end
        it 'values include: supplied, approximate, and uncertain' do
          expect(@c.certainty.sort).to eq([:approximate, :supplied, :uncertain])
        end
        it 'returns 1 token for 2002' do
          expect(@c.type_string).to eq('number4')
        end
      end
    end

    context 'c. 2002' do
      before(:all) do
        @c = check('c. 2002')
      end
      it 'values include: approximate' do
        expect(@c.certainty).to eq([:approximate])
      end
      it 'returns 1 token for 2002' do
        expect(@c.type_string).to eq('number4')
      end
    end

    context '[1997]-[1998]' do
      before(:all) do
        @c = check('[1997]-[1998]')
      end
      it 'no values' do
        expect(@c.certainty).to be_empty
      end
      it 'returns all original tokens' do
        pm = Emendate.prep_for('[1997]-[1998]', :convert_months)
        expect(@c.type_string).to eq(pm.tokens.type_string)
      end
    end

    context '[1667,1668,1670..1672]' do
      context 'edtf handling for square brackets' do
        before(:all) do
          @c = check('[1667,1668,1670..1672]', square_bracket_interpretation: :edtf_set)
        end
        it 'certainty is one_of_set' do
          expect(@c.certainty).to eq([:one_of_set])
        end
        it 'removes square brackets from result' do
          expected = 'number4 comma number4 comma number4 double_dot number4'
          expect(@c.type_string).to eq(expected)
        end
      end
    end

    context '{1667,1668,1670..1672}' do
      before(:all) do
        @c = check('{1667,1668,1670..1672}')
      end
      it 'certainty is one_of_set' do
        expect(@c.certainty).to eq([:all_of_set])
      end
      it 'removes square brackets from result' do
        expected = 'number4 comma number4 comma number4 double_dot number4'
        expect(@c.type_string).to eq(expected)
      end
    end
    
  end
end
