module VCLog

  # = Change Log Entry class
  #
  class Change

    include Comparable

    attr_accessor :author
    attr_accessor :date
    attr_accessor :revision
    attr_accessor :message
    attr_accessor :type

    #
    def initialize(rev, date, author, message, type=nil)
      self.revision = rev
      self.date     = date
      self.author   = author
      self.type     = type
      self.message  = message
    end

    #
    def author=(author)
      @author = author.strip
    end

    #
    def message=(note)
      @message = note.strip
    end

    #
    def type
      @type ||= split_type(message)
    end

    #def clean_type(type)
    #  case type.to_s
    #  when 'maj', 'major' then :major
    #  when 'min', 'minor' then :minor
    #  when 'bug'          then :bug
    #  when ''             then :other
    #  else
    #    type.to_sym
    #  end
    #end

    #
    def type_phrase
      case type.to_s
      when 'maj', 'major'
        'Major Enhancements'
      when 'min', 'minor'
        'Minor Enhancements'
      when 'bug'
        'Bug Fixes'
      when ''
        'General Enhancements'
      when '-'
        'Administrative Changes'
      else
        "#{type.capitalize} Enhancements"
      end
    end

    #
    def type_number
      case type.to_s.downcase
      when 'maj', 'major'
        0
      when 'min', 'minor'
        1
      when 'bug'
        2
      when ''
        4
      when '-'
        5
      else # other
        3
      end
    end

    #
    def <=>(other)
      other.date <=> date
    end

    def inspect
      "#<Change:#{object_id} #{date}>"
    end

    def to_h
      { 'author'   => @author,
        'date'     => @date,
        'revision' => @revison,
        'message'  => @message,
        'type'     => @type
      }
    end

    def to_json
      to_h.to_json
    end

    def to_yaml(*args)
      to_h.to_yaml(*args)
    end

    private

    # Looks for a "[type]" indicator at the end of the commit message.
    # If that is not found, it looks at front of message for
    # "[type]" or "[type]:". Failing that it tries just "type:".
    #
    def split_type(note)
      note = note.strip
      if md = /\[(.*?)\]\Z/.match(note)
        t = md[1].strip.downcase
        n = note[0...(md.begin(0))]
      elsif md = /\A\[(.*?)\]\:?/.match(note)
        t = md[1].strip.downcase
        n = note[md.end(0)..-1]
      elsif md = /\A(\w+?)\:/.match(note)
        t = md[1].strip.downcase
        n = note[md.end(0)..-1]
      else
        n, t = note, nil
      end
      n.gsub!(/^\s*?\n/m,'') # remove blank lines
      return n, t
    end

  end #class Entry

end
