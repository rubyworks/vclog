require 'vclog/heuristics/label'
require 'vclog/heuristics/rule'

module VCLog

  #
  class Heuristics

    # Load heuristics from a designated file.
    #
    # @param file [String] configuration file
    #
    def self.load(file)
      raise LoadError unless File.exist?(file)
      new{ instance_eval(File.read(file), file) }
    end

    #
    def initialize(&block)
      @rules  = []
      @labels = {}

      instance_eval(&block) if block
    end

    #
    def lookup(message)
      type_msg = nil
      @rules.find{|rule| type_msg = rule.call(message)}
      type, msg = *type_msg
      if type
        type = type.to_sym
        if @labels.key?(type)
           @labels[type].to_a + [msg || message]
        else
          [type, 0, "#{type.to_s.capitalize} Enhancements", msg || message]
        end
      else
        [nil, 0, 'General Enhancements', msg || message]
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

    # Default settings.
    def default
      set :major,  1, "Major Enhancements"
      set :bug,    0, "Bug Fixes"
      set :minor, -1, "Minor Enhancements"
      set :doc,   -1, "Documentation Changes"
      set :admin, -2, "Administrative Changes"

      on /^(\w+):/ do |msg, md|
        word = md[1]
        [word.to_sym, md.post_match]
      end

      on /\[(\w+)\]\s*$/ do |msg, md|
        word = md[1]
        [word.to_sym, md.pre_match]
      end

      on /updated? (README|PROFILE|PACKAGE|VERSION|MANIFEST)/ do
        :admin
      end

      on /(bump|bumped|prepare) version/ do
        :admin
      end
    end

  end

end
