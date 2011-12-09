module VCLog

  # The Change class models an entry in a change log.
  #
  class ChangePoint

    attr_accessor :type

    attr_accessor :level

    attr_accessor :label

    #
    def initialize(change, message)
      @change  = change
      @message = message.strip
      @level   = 0
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
        super(s,*a,&b)
      end
    end

    # Change points do not have sub-points.
    def points
      []
    end

    #
    def apply_heuristics(heuristics)
      type, level, label, msg = *heuristics.lookup(self)

      self.type    = type
      self.level   = level
      self.label   = label
      self.message = msg if msg
    end

    #
    def to_h
      { 'author'   => change.author,
        'date'     => change.date,
        'revision' => change.revision,
        'message'  => message,
        'type'     => type
      }
    end

  end

end
