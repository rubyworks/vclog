require 'vclog/kernel'
require 'vclog/change_point'

module VCLog

  # The Change class models an entry in a change log.
  #
  class Change

    include Comparable

    # Commit reference id.
    attr_accessor :id

    # Date/time of commit.
    attr_accessor :date

    # Committer.
    attr_accessor :author

    # Commit message.
    attr_accessor :message

    # List of files changed in the commit.
    attr_accessor :files

    attr_accessor :type
    attr_accessor :level
    attr_accessor :label

    #
    def initialize(data={})
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
    alias_method :ref,  :id
    alias_method :ref=, :id=
    alias_method :reference,  :id
    alias_method :reference=, :id=

    # Alternate name for id.
    #
    # @deprecated
    alias_method :rev,  :id
    alias_method :rev=, :id=

    # Alternate name for id.
    #
    # @deprecated
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

    #
    def <=>(other)
      other.date <=> date
    end

    def inspect
      "#<Change:#{object_id} #{date}>"
    end

    # TODO: Rename revision to `referece` or `ref`.

    #
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
      type, level, label, msg = *heuristics.lookup(self)

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

    def points
      @points ||= parse_points
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

    # TODO: Improve the parsing of point messages.
    def parse_points
      point_messages = message.split(/^[\*]/)
      point_messages.map do |msg|
        ChangePoint.new(self, msg)
      end
    end

  end

end
