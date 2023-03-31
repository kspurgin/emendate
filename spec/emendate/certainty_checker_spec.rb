# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::CertaintyChecker do
  subject(:step){ described_class }

  describe '.call' do
    let(:tokens){ prepped_for(string: string, target: step) }
    let(:result) do
      step.call(tokens)
        .value!
    end

    context 'with c. 2002' do
      let(:string){ 'c. 2002' }

      it 'values include: approximate' do
        expect(result.certainty).to eq([:approximate])
      end

      it 'returns 1 token for 2002' do
        expect(result.type_string).to eq('number4')
      end
    end

    context 'with 1920 ca' do
      let(:string){ '1920 ca' }

      it 'values include: approximate' do
        expect(result.certainty).to eq([:approximate])
      end

      it 'returns 1 token for 1920' do
        expect(result.type_string).to eq('number4')
      end
    end

    context 'with 2004-06~' do
      let(:string){ '2004-06~' }

      it 'values include: approximate' do
        expect(result.certainty).to eq([:approximate])
      end

      it 'returns tokens with tilde removed' do
        expect(result.type_string).to eq('number4 hyphen number1or2')
      end
    end

    context 'with 2004-06%' do
      let(:string){ '2004-06%' }

      it 'values include: approximate, uncertain' do
        expect(result.certainty.sort).to eq(%i[approximate uncertain])
      end

      it 'returns tokens with tilde removed' do
        expect(result.type_string).to eq('number4 hyphen number1or2')
      end
    end

    context 'with 2004-06~-11' do
      let(:string){ '2004-06~-11' }

      it 'returns tokens with tilde removed' do
        expect(result.type_string).to eq(
          'number4 hyphen number1or2 hyphen number1or2'
        )
      end

      it 'sets uncertainty on year token to leftward_approximate' do
        expect(result[2].certainty).to eq([:leftward_approximate])
      end
    end

    context 'with ~2004-06-%11' do
      let(:string){ '~2004-06-%11' }

      it 'returns tokens with uncertainty indicators removed' do
        expect(result.type_string).to eq(
          'number4 hyphen number1or2 hyphen number1or2'
        )
      end

      it 'sets uncertainty on year token to approximate' do
        expect(result[0].certainty).to eq([:approximate])
      end

      it 'sets uncertainty on day token to approximate and uncertain' do
        expect(result[4].certainty.sort).to eq(%i[approximate uncertain])
      end
    end

    context 'with inferred handling for square brackets' do
      before do
        Emendate::Options.new({square_bracket_interpretation: :inferred_date})
      end
      after{ Emendate.reset_config }

      context 'with [circa 2002?] and default square bracket handling' do
        let(:string){ '[circa 2002?]' }

        it 'values include: approximate and uncertain' do
          expect(result.certainty.sort).to eq(%i[approximate inferred uncertain])
        end

        it 'returns 1 token for 2002' do
          expect(result.type_string).to eq('number4')
        end

        it 'tags result as inferred' do
          expect(result.inferred_date).to be true
        end
      end

      context 'with [1997]-[1998]' do
        let(:string){ '[1997]-[1998]' }

        it 'no values' do
          expect(result.certainty).to be_empty
        end

        it 'returns all original tokens' do
          expect(result.type_string).to eq(tokens.type_string)
        end
      end

        context 'with [1997 or 1999]' do
          let(:string){ '[1997 or 1999]' }

          it 'certainty is inferred and one_of_set' do
            expect(result.certainty.sort).to eq(%i[inferred one_of_set])
          end

          it 'removes square brackets from result' do
            expected = 'number4 date_separator number4'
            expect(result.type_string).to eq(expected)
          end
        end
    end

    context 'with edtf handling for square brackets' do
      before do
        Emendate::Options.new({square_bracket_interpretation: :edtf_set})
      end
      after{ Emendate.reset_config }

      context 'with [1667,1668,1670..1672]' do
        let(:string){ '[1667,1668,1670..1672]' }

        it 'certainty is one_of_set' do
          expect(result.certainty).to eq([:one_of_set])
        end

        it 'removes square brackets from result' do
          expected = 'number4 comma number4 comma number4 double_dot number4'
          expect(result.type_string).to eq(expected)
        end
      end

      context 'with [1997 or 1999]' do
        let(:string){ '[1997 or 1999]' }

        it 'certainty is one_of_set' do
          expect(result.certainty.sort).to eq(%i[one_of_set])
        end

        it 'removes square brackets from result' do
          expected = 'number4 date_separator number4'
          expect(result.type_string).to eq(expected)
        end
      end
    end

    context 'with {1667,1668,1670..1672}' do
      let(:string){ '{1667,1668,1670..1672}' }

      it 'certainty is all_of_set' do
        expect(result.certainty).to eq([:all_of_set])
      end

      it 'removes curly brackets from result' do
        expected = 'number4 comma number4 comma number4 double_dot number4'
        expect(result.type_string).to eq(expected)
      end
    end
  end
end
