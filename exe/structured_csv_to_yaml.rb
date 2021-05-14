#!/usr/bin/env ruby
require "structured_csv/csv2yaml"

csvfile = ARGV.pop
raise "first argument must be a .csv file!" unless /\.csv$/.match?(csvfile)

outfile = csvfile.gsub(/csv$/, "yaml")

IO.write(
  outfile,
  StructuredCsv::CsvTo2Yaml.convert(csvfile).to_yaml,
)

# pp Csv2Yaml.convert(filename)
