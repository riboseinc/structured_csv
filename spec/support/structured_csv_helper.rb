require "tmpdir"

module StructuredCsv
  module Helper
    def create_tmp_dir
      dir = Dir.mktmpdir("structured_csv")
      Dir.glob(dir).first # expand the ~1 suffix on Windows
    end
  end
end
