# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::CertaintyChecker do
  before{ Emendate.reset_config }
  
  def check(str, options = {})
    pm = Emendate.prep_for(str, :certainty_check, options)
    cc = Emendate::CertaintyChecker.new(tokens: pm.tokens)
    cc.check
  end

  describe '#check' do
    context 'with [circa 2002?]' do
      context 'with default square bracket handling' do
        before(:all) do
          @c = check('[circa 2002?]')
        end

        it 'values include: approximate and uncertain' do
          expect(@c.certainty.sort).to eq(%i[approximate inferred uncertain])
        end

        it 'returns 1 token for 2002' do
          expect(@c.type_string).to eq('number4')
        end

        it 'tags result as inferred' do
          expect(@c.inferred_date).to be true
        end
      end
    end

    context 'with c. 2002' do
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

    context 'with 2004-06~' do
      before(:all) do
        @c = check('2004-06~')
      end

      it 'values include: approximate' do
        expect(@c.certainty).to eq([:approximate])
      end

      it 'returns tokens with tilde removed' do
        expect(@c.type_string).to eq('number4 hyphen number1or2')
      end
    end

    context 'with 2004-06%' do
      before(:all) do
        @c = check('2004-06%')
      end

      it 'values include: approximate, uncertain' do
        expect(@c.certainty.sort).to eq(%i[approximate uncertain])
      end

      it 'returns tokens with tilde removed' do
        expect(@c.type_string).to eq('number4 hyphen number1or2')
      end
    end

    context 'with 2004-06~-11' do
      before(:all) do
        @c = check('2004-06~-11')
      end

      it 'returns tokens with tilde removed' do
        expect(@c.type_string).to eq('number4 hyphen number1or2 hyphen number1or2')
      end

      it 'sets uncertainty on year token to leftward_approximate' do
        expect(@c[2].certainty).to eq([:leftward_approximate])
      end
    end

    context 'with ~2004-06-%11' do
      before(:all) do
        @c = check('~2004-06-%11')
      end

      it 'returns tokens with uncertainty indicators removed' do
        expect(@c.type_string).to eq('number4 hyphen number1or2 hyphen number1or2')
      end

      it 'sets uncertainty on year token to approximate' do
        expect(@c[0].certainty).to eq([:approximate])
      end

      it 'sets uncertainty on day token to approximate and uncertain' do
        expect(@c[4].certainty.sort).to eq(%i[approximate uncertain])
      end
    end

    context 'with [1997]-[1998]' do
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

    context 'with [1667,1668,1670..1672]' do
      context 'with edtf handling for square brackets' do
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

    context 'with [1997 or 1999]' do
      context 'with square brackets as inferred_date' do
        before(:all) do
          @c = check('[1997 or 1999]', square_bracket_interpretation: :inferred_date)
        end

        it 'certainty is inferred and one_of_set' do
          expect(@c.certainty.sort).to eq(%i[inferred one_of_set])
        end

        it 'removes square brackets from result' do
          expected = 'number4 number4'
          expect(@c.type_string).to eq(expected)
        end
      end

      context 'with square brackets as edtf_set' do
        before(:all) do
          @c = check('[1997 or 1999]', square_bracket_interpretation: :edtf_set)
        end

        it 'certainty is one_of_set' do
          expect(@c.certainty.sort).to eq(%i[one_of_set])
        end

        it 'removes square brackets from result' do
          expected = 'number4 number4'
          expect(@c.type_string).to eq(expected)
        end
      end
    end

    context 'with {1667,1668,1670..1672}' do
      before(:all) do
        @c = check('{1667,1668,1670..1672}')
      end

      it 'certainty is all_of_set' do
        expect(@c.certainty).to eq([:all_of_set])
      end

      it 'removes curly brackets from result' do
        expected = 'number4 comma number4 comma number4 double_dot number4'
        expect(@c.type_string).to eq(expected)
      end
    end

  end
end
