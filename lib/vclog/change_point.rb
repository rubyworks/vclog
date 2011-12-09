module VCLog

  # The Change class models an entry in a change log.
  #
  class ChangePoint

    #
    def initialize(change, message)
      @change  = change
      @message = message
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

  end

end
