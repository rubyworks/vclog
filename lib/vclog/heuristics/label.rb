module VCLog

  class Heuristics

    #
    #
    class Type
      #
      def initialize(type, level, label)
        @type  = type.to_sym
        @level = level.to_i
        @label = label.to_s
      end

      attr :type

      attr :level

      attr :label

      #
      def to_a
        [type, level, label]
      end
    end

  end

end
