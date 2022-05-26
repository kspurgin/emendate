# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::Examples::Tester do
  let(:opt){ nil }
  let(:example){ Emendate::Examples::TestableExample.new(test_rows(str, opt)) }
  let(:klass){ described_class.build(test: test, example: example) }

  context 'with date_start_full test' do
    let(:test){ 'date_start_full' }

    describe 'tested_result' do
      let(:result){ klass.tested_result }

      context 'with testable example' do
        context 'with multiple rows for example' do
          let(:str){ '1997, 1999' }

          it 'returns expected' do
            expect(result).to eq('1997-01-01|1999-01-01')
          end
        end

        context 'with single row example' do
          let(:str){ '2002' }

          it 'returns expected' do
            expect(result).to eq('2002-01-01')
          end
        end
      end

      context 'with untestable example' do
        let(:str){ '2002' }
        let(:opt){ 'unknown_opt: :foo' }

        it 'returns expected' do
          expect(result).to be_nil
        end
      end
    end

    describe 'expected_result' do
      let(:result){ klass.expected_result }

      context 'with testable example' do
        context 'with multiple rows for example' do
          let(:str){ '1997, 1999' }

          it 'returns expected' do
            expect(result).to eq('1997-01-01|1999-01-01')
          end
        end

        context 'with single row example' do
          let(:str){ '2002' }

          it 'returns expected' do
            expect(result).to eq('2002-01-01')
          end
        end
      end

      context 'with untestable example' do
        let(:str){ '2002' }
        let(:opt){ 'unknown_opt: :foo' }

        it 'returns expected' do
          expect(result).to be_nil
        end
      end
    end
  end

  context 'with result_warnings test' do
    let(:test){ 'result_warnings' }

    describe 'tested_result' do
      let(:result){ klass.tested_result }

      context 'with testable example' do
        context 'with single row example' do
          let(:str){ 'b' }

          it 'returns expected' do
            expect(result).to eq('Untokenizable sequences: b')
          end
        end
      end

      context 'with untestable example' do
        let(:str){ '2002' }
        let(:opt){ 'unknown_opt: :foo' }

        it 'returns expected' do
          expect(result).to be_nil
        end
      end
    end

    describe 'expected_result' do
      let(:result){ klass.expected_result }

      context 'with testable example' do
        context 'with single row example' do
          let(:str){ 'b' }

          it 'returns expected' do
            expect(result).to eq('Untokenizable sequences: b')
          end
        end
      end

      context 'with untestable example' do
        let(:str){ '2002' }
        let(:opt){ 'unknown_opt: :foo' }

        it 'returns expected' do
          expect(result).to be_nil
        end
      end
    end
  end

  context 'with translation_lyrasis_pseudo_edtf' do
    let(:test){ 'translation_lyrasis_pseudo_edtf' }

    describe 'tested_result' do
      let(:result){ klass.tested_result }

      context 'with testable example' do
        context 'with single row example' do
          let(:str){ '2002' }

          it 'returns expected' do
            expect(result).to eq('2002')
          end
        end
      end

      context 'with untestable example' do
        let(:str){ '2002' }
        let(:opt){ 'unknown_opt: :foo' }

        it 'returns expected' do
          expect(result).to be_nil
        end
      end
    end

    describe 'expected_result' do
      let(:result){ klass.expected_result }

      context 'with testable example' do
        context 'with single row example' do
          let(:str){ '2002' }

          it 'returns expected' do
            expect(result).to eq('2002')
          end
        end
      end

      context 'with untestable example' do
        let(:str){ '2002' }
        let(:opt){ 'unknown_opt: :foo' }

        it 'returns expected' do
          expect(result).to be_nil
        end
      end
    end
  end
end

