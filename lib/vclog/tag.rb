module VCLog

  class Tag
    attr_accessor :name
    attr_accessor :date
    attr_accessor :author
    attr_accessor :message

    attr_accessor :commit

    #
    def initialize(data={})
      @commit = Change.new
      data.each do |k,v|
        __send__("#{k}=", v)
      end
    end

    #
    def name=(name)
      @name = (name || 'HEAD').strip
    end

    #
    alias_method :label,  :name
    alias_method :label=, :name=

    #
    alias_method :tag,  :name
    alias_method :tag=, :name=

    #
    def author=(author)
      @author = author.to_s.strip
    end

    alias_method :tagger,  :author
    alias_method :tagger=, :author=

    alias_method :who,  :author
    alias_method :who=, :author=

    #
    def date=(date)
      @date = parse_date(date)
    end

    #
    def message=(msg)
      @message = msg.strip
    end

    alias_method :msg,  :message
    alias_method :msg=, :message=


    #
    def commit_id
      @commit.id
    end

    #
    def commit_id=(id)
      @commit.id = id
    end

    #
    alias_method :id,  :commit_id
    alias_method :id=, :commit_id=

    #
    alias_method :revision,  :commit_id
    alias_method :revision=, :commit_id=

    #
    def commit_date
      @commit.date ||= date
    end

    #
    def commit_date=(date)
      @commit.date = date
    end

    #
    def to_json
      to_h.to_json
    end

    #
    def to_h
      {
        'name'    => name,
        'date'    => date,
        'author'  => author,
        'message' => message
      }
    end

    #
    def inspect
      "<Tag #{name} #{date.strftime('%Y-%m-%d %H:%M:%S')}>"
    end

    # Normal tag order is the reverse typical sorts.
    def <=>(other)
      return -1 if name == 'HEAD'
      other.name <=> name
    end

    private

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
