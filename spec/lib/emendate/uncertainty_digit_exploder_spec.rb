require 'spec_helper'

RSpec.describe Emendate::UncertaintyDigitExploder do
  def explode(str, options = {})
    pm = Emendate.prep_for(str, :explode_uncertainty_digits, options)
    ude = Emendate::UncertaintyDigitExploder.new(tokens: pm.tokens, options: pm.options)
    ude.explode
  end

  describe '#explode' do
    context '199u' do
      xit '1990 - 1999' do
        e = explode('199u').map(&:lexeme).join(' ')
        expect(e).to eq('1990 - 1999')
      end
    end
    context '19XX' do
      xit '1900 - 1999' do
        e = explode('19XX').map(&:lexeme).join(' ')
        expect(e).to eq('1900 - 1999')
      end
    end
    context '1985-04-XX' do
      xit 'returns DatePart with type = :unspecified_date_part' do
        e = explode('1985-04-XX').type_string
        expect(e).to eq('number4 hyphen number1or2 hyphen unspecified_date_part')
      end
    end

    context 'XXXX-04-XX' do
      xit 'returns two DateParts with type = :unspecified_date_part' do
        e = explode('XXXX-04-XX').type_string
        expect(e).to eq('unspecified_date_part hyphen number1or2 hyphen unspecified_date_part')
      end
    end
  end
end
