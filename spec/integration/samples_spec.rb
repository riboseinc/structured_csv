require "spec_helper"

RSpec.describe "samples" do
  describe "conversion" do
    after do
      Dir["samples/*.tmp"].each do |tmpfile|
        FileUtils.rm(tmpfile)
      end
    end

    it "does not fail" do
      Dir["samples/*.csv"].each do |csv_file_name|
        `exe/structured_csv_to_yaml #{csv_file_name}`
        expect($CHILD_STATUS.success?).to be true
      end
    end

    it "agrees with generated YAML files" do
      Dir["samples/*.csv"].each do |csv_file_name|
        out_file_name = csv_file_name.gsub(/csv$/, "yaml")
        out_file_name_for_comparison = "#{out_file_name}.tmp"
        FileUtils.cp(out_file_name, out_file_name_for_comparison)
        `exe/structured_csv_to_yaml #{csv_file_name}`
        expect(File.read(out_file_name)).to eql File.read(out_file_name_for_comparison)
      end
    end
  end
end
