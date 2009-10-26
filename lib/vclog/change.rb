module VCLog

  # = Change Log Entry class
  #
  class Change

    include Comparable

    attr_accessor :author
    attr_accessor :date
    attr_accessor :revison
    attr_accessor :message
    attr_accessor :type

    #
    def initialize(rev, date, author, message, type=nil)
      self.revison = rev      #opts[:revison] || opts[:rev]
      self.date    = date     #opts[:date]    || opts[:when]
      self.author  = author   #opts[:author]  || opts[:who]
      self.type    = type     #opts[:type]
      self.message = message  #opts[:message] || opts[:msg]
    end

    #
    def author=(author)
      @author = author.strip
    end

    def message=(note)
      @message = note.strip
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
      "#<Entry:#{object_id} #{date}>"
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

  end #class Entry

end
