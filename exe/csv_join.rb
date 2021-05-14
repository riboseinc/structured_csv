#!/usr/bin/env ruby
require "structured_csv/csv_join"

csvdir = ARGV.pop
outfile = Pathname.new(csvdir).sub_ext(".csv").to_s

# puts outfile

StructuredCsv::CsvJoin.convert(csvdir, outfile)

# puts CsvJoin.convert(csvdir)
