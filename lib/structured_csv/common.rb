require "csv"

module StructuredCsv
  module Common
    def self.load_csv(csvfile)
      # warn csvfile

      content = File.read(csvfile, encoding: "bom|utf-8").scrub
      CSV.parse(content, liberal_parsing: true, encoding: "UTF-8")
    end
  end
end
