require "spec_helper"

RSpec.describe StructuredCsv::Common do
  describe ".load_csv" do
    let(:command) { described_class.method(:load_csv) }
    let(:csv_content) do
      <<~EOF
        a,b,c
        d,e,f
      EOF
    end
    let(:tmp_dir) { create_tmp_dir }
    let(:csv_file) do
      name = File.join(tmp_dir, "temp.csv")
      File.write(name, csv_content)
      name
    end

    it "reads the CSV" do
      expect(command.call(csv_file)).not_to be_nil
    end

    it "parses the CSV" do
      expect(command.call(csv_file)).to eql [%w[a b c], %w[d e f]]
    end
  end
end
