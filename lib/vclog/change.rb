require 'vclog/kernel'

module VCLog

  # The Change class models an extry in a change log.
  #
  class Change

    include Comparable

    attr_accessor :id
    attr_accessor :date
    attr_accessor :author
    attr_accessor :message

    attr_accessor :type
    attr_accessor :level
    attr_accessor :label

    #
    def initialize(data={}) #rev, date, author, message, type, level, label
      data.each do |k,v|
        __send__("#{k}=", v)
      end
    end

    #
    def author=(author)
      @author = author.strip
    end

    #
    def date=(date)
      @date = parse_date(date)
    end

    # Alternate name for id.
    alias_method :rev,  :id
    alias_method :rev=, :id=

    # Alternate name for id.
    alias_method :revision,  :id
    alias_method :revision=, :id=

    # Alternate name for message.
    alias_method :msg,  :message
    alias_method :msg=, :message=


    # Alias for author.
    alias_method :who,  :author
    alias_method :who=, :author=


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

=begin
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
        "#{type.to_s.capitalize} Enhancements"
      end
    end
=end

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
        'revision' => @revision,
        'message'  => @message,
        'type'     => @type
      }
    end

    #def to_json
    #  to_h.to_json
    #end

    #def to_yaml(*args)
    #  to_h.to_yaml(*args)
    #end

    def apply_heuristics(heuristics)
      type, level, label, msg = *heuristics.lookup(message)

      self.type    = type
      self.level   = level
      self.label   = label
      self.message = msg || @message
    end

=begin
    # Looks for a "[type]" indicator at the end of the commit message.
    # If that is not found, it looks at front of message for
    # "[type]" or "[type]:". Failing that it tries just "type:".
    #
    def split_type(note)
      note = note.to_s.strip
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
=end

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
