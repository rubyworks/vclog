require 'vclog/kernel'

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
    attr_accessor :level
    attr_accessor :label

    #
    def initialize(rev, date, author, message, type, level, label)
      self.revision = rev
      self.date     = date
      self.author   = author
      self.message  = message
      self.type     = type
      self.level    = level
      self.label    = label
    end

    #
    def author=(author)
      @author = author.strip
    end

    # Alternate name for revision.
    alias_method :rev,  :revision
    alias_method :rev=, :revision=

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

  end #class Entry

end
