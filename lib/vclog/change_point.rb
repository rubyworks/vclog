module VCLog

  # The Change class models an entry in a change log.
  #
  class ChangePoint

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

    #
    def initialize(change, message)
      @change  = change
      @message = message.strip

      @label = nil
      @level = nil
    end

    # Change from which point is derived.
    attr :change

    # The point's message.
    attr_accessor :message
    alias_method :msg,  :message
    alias_method :msg=, :message=

    # Delegate missing methods to +change+.
    def method_missing(s,*a,&b)
      if @change.respond_to?(s)
        @change.send(s,*a,&b)
      else
p caller
        super(s,*a,&b)
      end
    end

    # Change points do not have sub-points.
    def points
      []
    end

    # Apply heuristic rules to change.
    def apply_heuristics(heuristics)
      heuristics.apply(self)
    end

    #
    def to_h
      { 'author'   => change.author,
        'date'     => change.date,
        'id'       => change.id,
        'message'  => message,
        'type'     => type
      }
    end

    #
    def to_s(*)
      message
    end

  end

end
