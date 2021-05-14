require 'spec_helper'

RSpec.describe StructuredCsv::Common do
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
end
