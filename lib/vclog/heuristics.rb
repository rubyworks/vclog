module VCLog

  #
  class Heuristics

    # Load heuristics from a configruation file.
    #
    # config - the configuration directory
    #
    def self.load(file)
      if file
        raise LoadError unless File.exist?(file)
      else
        file = File.dirname(__FILE__) + '/heuristics/default.rb'
      end

      h = new
      h.instance_eval(File.read(file), file)
      h
    end

    #
    def initialize
      @rules  = []
      @labels = {}
    end

    #
    def lookup(message)
      type = nil
      @rules.find{ |rule| type = rule.call(message) }
      if type
        type = type.to_sym
        if @labels.key?(type)
           @labels[type].to_a
        else
          [type, 0, "#{type.to_s.capitalize} Enhancements"]
        end
      else
        [nil, 0, 'General Enhancements']
      end
    end

    #
    def on(pattern, &block)
      @rules << Rule.new(pattern, &block)
    end

    #
    def set(type, level, label)
      @labels[type.to_sym] = Label.new(type, level, label)
    end

    #
    class Label
      #
      def initialize(type, level, label)
        @type  = type
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

    #
    class Rule
      def initialize(pattern, &block)
        @pattern = pattern
        @block   = block        
      end

      def call(message)
        if md = @pattern.match(message)
          @block.call(*md[1..-1])
        else
          nil
        end
      end
    end

  end

end
