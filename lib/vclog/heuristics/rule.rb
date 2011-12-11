module VCLog

  class Heuristics

    # Defines a categorization rule for commits.
    #
    class Rule

      # Initialize a new log rule.
      #
      # @param [Regexp] pattern
      #   An optional regular expression to match agains the commit message.
      #   If the pattern does not match the commit message than the rule 
      #   does not apply.
      #
      # @yieldparam [Change]
      #   An encapsulation of the commit.
      #
      # @yieldreturn [Boolean]
      #   If the return value is +nil+ or +false+, the rule does not apply.
      #   If a rule does not apply then be sure not to alter the commit!
      #
      def initialize(pattern=nil, &block)
        @pattern = pattern
        @block   = block        
      end

      # Message pattern to match for the rule to apply.
      attr :pattern

      # Process the rule.
      #
      # @since 1.9.0 
      #   If using a message pattern and the block takes two arguments
      #   then the first will be the commit object, not the message as
      #   was the case in older versions.
      #
      def call(commit)
        if pattern
          call_pattern(commit)
        else
          call_commit(commit)
        end
      end

     private

      # 
      def call_pattern(commit)
        if matchdata = @pattern.match(commit.message)
          #case @block.arity
          #when 0
          #  @block.call
          #when 1
          #  @block.call(matchdata)
          #else
            @block.call(commit, matchdata)
          #end
        else
          nil
        end
      end

      #
      def call_commit(commit)
        @block.call(commit)
      end

    end

  end

end
