# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::CertaintyChecker do
  subject{ described_class.call(tokens).value! }

  describe '.call' do
    let(:tokens){ prepped_for(string: string, target: described_class) }

    context 'with c. 2002' do
      let(:string){ 'c. 2002' }

      it 'values include: approximate' do
        expect(subject.certainty).to eq([:approximate])
        expect(subject.type_string).to eq('number4')
        expect(subject.lexeme).to eq(string)
      end
    end

    context 'with 1920 ca' do
      let(:string){ '1920 ca' }

      it 'has expected lexeme' do
        expect(subject.lexeme).to eq(string)
        expect(subject.certainty).to eq([:approximate])
        expect(subject.type_string).to eq('number4')
      end
    end

    context 'with 2020, possibly March' do
      let(:string){ '2020, possibly March' }

      it 'has expected lexeme' do
        expect(subject.lexeme).to eq(string)
        expect(subject.certainty).to eq([:uncertain_month])
        expect(subject.type_string).to eq('number4 comma month')
      end
    end

    context 'with 2004-06~' do
      let(:string){ '2004-06~' }

      it 'has expected lexeme' do
        expect(subject.lexeme).to eq(string)
        expect(subject.certainty).to eq([:approximate])
        expect(subject.type_string).to eq('number4 hyphen number1or2')
      end
    end

    context 'with 2004-06%' do
      let(:string){ '2004-06%' }

      it 'has expected lexeme' do
        expect(subject.lexeme).to eq(string)
        expect(subject.certainty.sort).to eq(%i[approximate uncertain])
        expect(subject.type_string).to eq('number4 hyphen number1or2')
      end
    end

    context 'with 2004-06~-11' do
      let(:string){ '2004-06~-11' }

      it 'has expected lexeme' do
        expect(subject.lexeme).to eq(string)
        expect(subject.type_string).to eq(
          'number4 hyphen number1or2 hyphen number1or2'
        )
        expect(subject[2].certainty).to eq([:leftward_approximate])
      end
    end

    context 'with ~2004-06-%11' do
      let(:string){ '~2004-06-%11' }

      it 'has expected lexeme' do
        expect(subject.lexeme).to eq(string)
      end

      it 'returns tokens with uncertainty indicators removed' do
        expect(subject.type_string).to eq(
          'number4 hyphen number1or2 hyphen number1or2'
        )
        expect(subject[0].certainty).to eq([:approximate])
        expect(subject[4].certainty.sort).to eq(%i[approximate uncertain])
      end
    end

    context 'with inferred handling for square brackets' do
      context 'with [circa 2002?] and default square bracket handling' do
        let(:string){ '[circa 2002?]' }

        it 'has expected lexeme' do
          expect(subject.lexeme).to eq(string)
          expect(subject.certainty.sort).to eq(
            %i[approximate inferred uncertain]
          )
          expect(subject.type_string).to eq('number4')
          expect(subject.inferred_date).to be true
        end
      end

      context 'with [1997]-[1998]' do
        let(:string){ '[1997]-[1998]' }

        it 'has expected lexeme' do
          expect(subject.lexeme).to eq(string)
          expect(subject.certainty).to be_empty
          expect(subject.type_string).to eq(tokens.type_string)
        end
      end

      context 'with [1997 or 1999]' do
        let(:string){ '[1997 or 1999]' }

        it 'has expected lexeme' do
          expect(subject.lexeme).to eq(string)
          expect(subject.certainty.sort).to eq(%i[inferred one_of_set])
          expected = 'number4 date_separator number4'
          expect(subject.type_string).to eq(expected)
        end

        context 'with `and_or_date_handling: :single_range`' do
          before do
            Emendate.config.options.and_or_date_handling = :single_range
          end

          it 'has expected lexeme' do
            expect(subject.lexeme).to eq(string)
            expect(subject.certainty.sort).to eq(%i[inferred])
            expected = 'number4 date_separator number4'
            expect(subject.type_string).to eq(expected)
          end
        end
      end
    end

    context 'with edtf handling for square brackets' do
      before do
        Emendate.config.options.square_bracket_interpretation = :edtf_set
      end

      context 'with [1667,1668,1670..1672]' do
        let(:string){ '[1667,1668,1670..1672]' }

        it 'has expected lexeme' do
          expect(subject.lexeme).to eq(string)
          expect(subject.certainty).to eq([:one_of_set])
          expected = 'number4 comma number4 comma number4 double_dot number4'
          expect(subject.type_string).to eq(expected)
        end
      end

      context 'with [1997 or 1999]' do
        let(:string){ '[1997 or 1999]' }

        it 'has expected lexeme' do
          expect(subject.lexeme).to eq(string)
          expect(subject.certainty.sort).to eq(%i[one_of_set])
          expected = 'number4 date_separator number4'
          expect(subject.type_string).to eq(expected)
        end
      end
    end

    context 'with {1667,1668,1670..1672}' do
      let(:string){ '{1667,1668,1670..1672}' }

      it 'has expected lexeme' do
        expect(subject.lexeme).to eq(string)
        expect(subject.certainty).to eq([:all_of_set])
        expected = 'number4 comma number4 comma number4 double_dot number4'
        expect(subject.type_string).to eq(expected)
      end
    end
  end
end
