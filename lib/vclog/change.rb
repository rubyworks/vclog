require 'vclog/change_point'

module VCLog

  # The Change class models an entry in a change log.
  #
  class Change

    include Comparable

    # Commit revision/reference id.
    attr_accessor :id

    # Date/time of commit.
    attr_accessor :date

    # Committer.
    attr_accessor :author

    # Commit message.
    attr_accessor :message

    # List of files changed in the commit.
    attr_accessor :files

    # Type of change, as assigned by hueristics.
    attr_accessor :type

    # The priority level of this change, as assigned by hueristics.
    # This can be `nil`, as Heuristics will always make sure a
    # commit has an inteer level before going out to template.
    attr_accessor :level

    # The descriptive label of this change, as assigned by hueristics.
    attr_accessor :label

    # ANSI color to apply. Actually this can be a list
    # of any support ansi gem terms, but usually it's 
    # just the color term, such as `:red`.
    attr_accessor :color

    # Setup new Change instance.
    def initialize(data={})
      @type  = :default
      @level = nil
      @label = nil
      @color = []

      data.each do |k,v|
        __send__("#{k}=", v)
      end
    end

    #
    # Set authors attributes, ensuring the value is stripped of white space.
    #
    def author=(author)
      @author = author.strip
    end

    #
    # Set date attribute, converting vale given to an instance of Time.
    #
    def date=(date)
      @date = parse_date(date)
    end

    #
    # Set the commit message.
    #
    def message=(msg)
      @message = msg

      lines = msg.lines.to_a
      @summary = lines.first.strip
      @details = lines[1..-1].join('').strip

      msg
    end

    #
    # Set the ANSI color terms.
    #
    # @param [Symbol,Array<Symbol>] code
    #   An ANSI gem recognized term, or array of such.
    #
    def color=(code)
      @color = [code].flatten
    end

    #
    def type=(type)
      @type = type.to_sym
    end

    # Alternate name for id.
    alias_method :rev,  :id
    alias_method :rev=, :id=

    # Alternate name for id.
    alias_method :revision,  :id
    alias_method :revision=, :id=

    # Alternate name for id.
    alias_method :ref,  :id
    alias_method :ref=, :id=

    # Alternate name for id.
    alias_method :reference,  :id
    alias_method :reference=, :id=

    # Alternate name for message.
    alias_method :msg,  :message
    alias_method :msg=, :message=

    # Alias for author.
    alias_method :who,  :author
    alias_method :who=, :author=

    attr_reader :summary

    attr_reader :details

    #
    # Compare changes by date.
    #
    def <=>(other)
      other.date <=> date
    end

    #
    # Inspection string of change object.
    #
    def inspect
      "#<Change:#{object_id} #{date}>"
    end

    #
    # Convert to Hash.
    #
    def to_h
      { 'author'   => self.author,
        'date'     => self.date,
        'id'       => self.id,
        'message'  => self.message,
        'type'     => self.type
      }
    end

    #
    # Apply heuristic rules to change.
    #
    def apply_heuristics(heuristics)
      heuristics.apply(self)
    end

    #
    # Parse point entries from commit message. Point entries
    # are outlined changes via line that start with an asterisk.
    #
    def points
      @points ||= parse_points
    end

    #
    # Output message with optional adjustments.
    #
    def to_s(opts={})
      if opts[:summary]
        summary
      else
        message.strip
      end
    end

   private

    #
    # Convert given +date+ into Time instance.
    #
    # @param [String,Data,Time] date
    #   A valid data/time string or object.
    #
    def parse_date(date)
      case date
      when Time
        date
      else
        Time.parse(date.to_s)
      end
    end

    #
    # Split message into individual points.
    #
    # @todo Improve the parsing of point messages.
    #
    def parse_points
      point_messages = message.split(/^\*/)
      point_messages.map do |msg|
        ChangePoint.new(self, msg)
      end
    end

  end

end
