module VCLog

  # The HistoryFile class will parse a history into an array
  # of release tags. Of course to do this, it assumes a specific
  # file format.
  #
  class HistoryFile

    FILE = /\Ahistory(\.\w+)?\z/i

    LINE = /^[=#]/
    VERS = /(\d+[._])+\d+/
    DATE = /(\d+[-])+\d+/

    # Alias for `File::FNM_CASEFOLD`.
    CASEFOLD = File::FNM_CASEFOLD

    # Release tags.
    attr :tags

    # Setup new HistoryFile instance.
    def initialize(source=nil)
      source = source.to_s
      if File.file?(source)
        @file = source
        @root = File.dirname(source)
      elsif File.directory?(source)
        @file = find(source)
        @root = source
      else
        @file = find(Dir.pwd)
        @root = Dir.pwd
      end
      raise "no history file" unless @file

      @tags = extract_tags
    end

    # Find the history file in a directory, whatever its case.
    def find(dir)
      name = Dir.children(dir).sort.find{ |f| FILE =~ f && File.file?(File.join(dir, f)) }
      name && File.join(dir, name)
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

    #
    def news
      tags.first.message
    end

  end

end
