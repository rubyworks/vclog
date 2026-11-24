module VCLog

  #
  class Tag

    #
    # Tag's commit id.
    #
    attr_accessor :id

    #
    # Tag name, which in this case is typically a version stamp.
    #
    attr_reader :name

    #
    # Date tag was made.
    #
    attr_reader :date

    #
    # Creator to the tag.
    #
    attr_reader :author

    #
    # Tag message.
    #
    attr_reader :message

    #
    # Last commit before Tag.
    #
    attr_accessor :commit

    #
    # @todo Hg is using this at the moment but it really shouldn't be here,
    #   since it is take care of by `commit.files`.
    #
    attr_accessor :files

    #
    # Setup new Tag intsance.
    #
    # If `:commit` is not provided, it is assume that the underlying SCM
    # simply creates tags as references to a commit. That is to say the tag
    # information and the commit information are one and the same. This is
    # the case for Hg, but not for Git, for instance.
    #
    def initialize(data={})
      @commit = data.delete(:commit) || Change.new(data)

      data.each do |k,v|
        __send__("#{k}=", v)
      end
    end

    #
    #  Set the tag name.
    #
    def name=(name)
      @name = (name || 'HEAD').strip
    end

    # Alias for +name+ attribute.
    alias_method :label,  :name
    alias_method :label=, :name=

    #
    alias_method :tag,  :name
    alias_method :tag=, :name=

    # Set author name, stripping white space.
    def author=(author)
      @author = author.to_s.strip
    end

    # Alias for +author+ attribute.
    alias_method :tagger,  :author
    alias_method :tagger=, :author=

    # Alias for +author+ attribute.
    alias_method :who,  :author
    alias_method :who=, :author=

    #
    # Set the tag date, converting +date+ to a Time object.
    #
    def date=(date)
      @date = parse_date(date)
    end

    #
    # Set the tag message.
    #
    def message=(msg)
      @message = msg.to_s.strip
    end

    #
    # Alias for +message+.
    #
    alias_method :msg,  :message
    alias_method :msg=, :message=

    #
    # Convert to Hash.
    #
    def to_h
      {
        'name'    => name,
        'date'    => date,
        'author'  => author,
        'message' => message,
        'commit'  => commit.to_h
      }
    end

    #
    # Inspection string for Tag.
    #
    def inspect
      dstr = date ? date.strftime('%Y-%m-%d %H:%M:%S') : '(date?)'
      "<Tag #{name} #{dstr}>"
    end

    #
    # Normal tag order is the reverse typical sorts.
    #
    def <=>(other)
      return  0 if name == other.name
      return -1 if name == 'HEAD'
      return  1 if other.name == 'HEAD'
      a, b = version_of(name), version_of(other.name)
      (a && b) ? (b <=> a) : (other.name <=> name)
    end

  private

    #
    # The tag's name as a version number, if it can be read as one, so
    # that 1.10 sorts after 1.9.
    #
    def version_of(name)
      Gem::Version.new(name.sub(/\A[^\d]*/, ''))
    rescue ArgumentError
      nil
    end

    #
    #
    #
    def parse_date(date)
      case date
      when Time
        date
      else
        Time.parse(date.to_s)
      end
    end

  end

end
