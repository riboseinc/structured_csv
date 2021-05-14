require "csv"
require "yaml"
require "pathname"

module StructuredCsv
  module CsvJoin
    def self.join(csv, section_name)
      first_row = nil
      last_row = -1

      warn "section_name #{section_name}"

      csv.each_with_index do |row, index|
        if first_row.nil? && Csv2Yaml.is_start_of_portion?(row, section_name)
          warn "found first"
          first_row = index + 1
          next
        end

        if !first_row.nil? && Csv2Yaml.is_row_empty?(row)
          warn "found last"
          last_row = index
          break
        end
      end

      warn "first #{first_row}  last #{last_row}"
      csv[first_row..last_row]
    end

    def self.convert(csvdir, outfile)
      raise "first argument must be a directory!" unless File.directory?(csvdir)

      csv = CSV.open(outfile, "wb", encoding: "UTF-8")

      csvfiles = Dir.glob(File.join(csvdir, "**", "*.csv")).sort
      raise "directory must contain .csv files!" if csvfiles.empty?

      # Assume all files use the same header structure as the first CSV file
      header = []
      csvheader = ""

      csvfiles.each do |csvfile|
        content = StructuredCsv::Common.load_csv(csvfile)

        csvheader = content.shift
        if header.empty?
          header = ["name"] + csvheader
          csv << header
        end

        basename = Pathname.new(csvfile).basename.sub_ext("").to_s
        content.each do |filerow|
          row = []
          filerow.each do |value|
            row << case value
                   when String
                     value.strip
                   else
                     value
                   end
          end

          all_empty = row.all? do |f|
            f.nil? || f.empty?
          end
          next if all_empty

          row.unshift(basename)

          csv << row
        end
      end

      csv.close
    end
  end
end
