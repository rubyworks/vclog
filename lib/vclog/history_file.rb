module VCLog

  # The HistoryFile class will parse a history into an array
  # of release tags. Of course to do this, it assumes a specific
  # file format.
  #
  class HistoryFile

    FILE = '{HISTORY,HISTORY.*}'

    LINE = /^[=#]/
    VERS = /(\d+[._])+\d+/
    DATE = /(\d+[-])+\d+/

    # Alias for `File::FNM_CASEFOLD`.
    CASEFOLD = File::FNM_CASEFOLD

    # Release tags.
    attr :tags

    # Setup new HistoryFile instance.
    def initialize(source=nil)
      if File.file?(source)
        @file = source
        @root = File.dirname(source)
      elsif File.directory?(source)
        @file = Dir.glob(File.join(source,FILE), CASEFOLD).first
        @root = source
      else
        @file = Dir.glob(FILE).first
        @root = Dir.pwd
      end
      raise "no history file" unless @file

      @tags = extract_tags
    end

    # Parse history file.
    def extract_tags
      tags = []
      desc = ''
      text = File.read(@file)
      text.lines.each do |line|
        if LINE =~ line
          vers = (VERS.match(line) || [])[0]
          date = (DATE.match(line) || [])[0]
          next unless vers
          tags << [vers, date, desc = '']
        else
          desc << line
        end
      end

      tags.map do |vers, date, desc|
        index = desc.index(/^Changes:/) || desc.index(/^\*/) || desc.size
        desc = desc[0...index].strip.fold
        #[vers, date, desc]
        Tag.new(:name=>vers, :date=>date, :msg=>desc)
      end
    end

  end

end
