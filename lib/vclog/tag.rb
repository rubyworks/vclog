module VCLog

  class Tag
    attr_accessor :revision
    attr_accessor :name
    attr_accessor :date
    attr_accessor :author
    attr_accessor :message

    #
    def initialize(name, rev, date, author, message)
      self.name     = name
      self.revision = rev
      self.date     = date
      self.author   = author
      self.message  = message
    end

    #
    def name=(name)
      @name = (name || 'HEAD').strip
    end

    #
    alias_method :label, :name

    #
    def author=(author)
      @author = author.to_s.strip
    end

    #
    def date=(date)
      case date
      when Time
        @date = date
      else
        @date = Time.parse(date.to_s)
      end
    end

    #
    def message=(msg)
      @message = msg.strip
    end

    alias_method :tagger, :author
    alias_method :tagger=, :author=

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
  end

end
