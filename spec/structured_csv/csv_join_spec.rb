require 'spec_helper'

RSpec.describe StructuredCsv::CsvJoin do
  describe '.join' do
    let(:command) { described_class.method(:join) }
    let(:csv) {
      CSV.parse(
      <<~EOF
      a,b,c
      test_section,1,2,3
      d,e,f
      h,i,j
EOF
      )
    }
    let(:section_name) { 'test_section' }

    it 'returns a specific portion of csv after encountering given section_name' do
      expect(command.call(csv, section_name)).to eql [%w[d e f], %w[h i j]]
    end

    it 'returns an array of arrays' do
      expect(command.call(csv, section_name)).to (be_kind_of Array).and all be_kind_of Array
    end
  end

  describe '.load_csv' do
    let(:command) { described_class.method(:load_csv) }
    let(:csv_content) {
      <<~EOF
      a,b,c
      d,e,f
EOF
    }
    let(:tmp_dir) { create_tmp_dir }
    let(:csv_file) {
      name = File.join(tmp_dir, 'temp.csv')
      File.write(name, csv_content)
      name
    }

    it 'reads the CSV' do
      expect(command.call(csv_file)).to_not be_nil
    end

    it 'parses the CSV' do
      expect(command.call(csv_file)).to eql [%w[a b c], %w[d e f]]
    end

  end

  describe '.convert' do
    let(:command) { described_class.method(:convert) }
    let(:outfile) { File.join(tmp_dir, 'outfile.yaml') }
    let(:csv_content) {
      <<~EOF
      a,b,c
      d,e,f
EOF
    }
    let(:tmp_dir) { create_tmp_dir }
    let(:csv_file) {
      name = File.join(tmp_dir, 'temp.csv')
      File.write(name, csv_content)
      name
    }

    context 'when first argument is not a directory' do
      it 'throws error' do
        expect{ command.call(csv_file, outfile) }.to raise_error RuntimeError
      end
    end

    context 'when given directory has no csv files' do
      it 'throws error' do
        expect{ command.call(tmp_dir, outfile) }.to raise_error RuntimeError
      end
    end

    context 'when given directory has csv files' do
      before do
        csv_file
        tmp_dir
        outfile
      end

      it 'does not throw error' do
        expect{ command.call(tmp_dir, outfile) }.to_not raise_error
      end

      it 'writes the correct output to given outfile' do
        command.call(tmp_dir, outfile)
        expect(File.read(outfile)).to eql "name,a,b,c\ntemp,d,e,f\n"
      end
    end

  end
end
