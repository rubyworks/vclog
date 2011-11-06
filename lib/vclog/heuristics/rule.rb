module VCLog

  class Heuristics

    #
    class Rule
      #
      def initialize(pattern, &block)
        @pattern = pattern
        @block   = block        
      end

      # Process the rule.
      def call(message)
        if matchdata = @pattern.match(message)
          case @block.arity
          when 0
            @block.call
          when 1
            @block.call(matchdata)
          else
            @block.call(message, matchdata)
          end
        else
          nil
        end
      end
    end

  end

end

