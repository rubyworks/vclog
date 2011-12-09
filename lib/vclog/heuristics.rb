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

      if block
        instance_eval(&block)
      else
        default
      end
    end

    #
    def lookup(commit)
      type_msg = nil

      @rules.find{|rule| type_msg = rule.call(commit)}

      type, msg = *type_msg

      msg = msg || commit.message

      if type
        type = type.to_sym
        if @labels.key?(type)
           @labels[type].to_a + [msg]
        else
          [type, 0, "#{type.to_s.capitalize} Enhancements", msg]
        end
      else
        default = @labels[:default]
        if default
          default.to_a + [msg]
        else
          [nil, 0, 'Nominal Changes', msg]
        end
      end
    end

    #
    def on(pattern=nil, &block)
      @rules << Rule.new(pattern, &block)
    end

    #
    def set(type, level, label)
      @labels[type.to_sym] = Label.new(type, level, label)
    end

    # Default settings.
    def default
      set :major,    2, "Major Enhancements"
      set :minor,    1, "Minor Enhancements"
      set :bug,      0, "Bug Fixes"
      set :doc,     -1, "Documentation Changes"
      set :test,    -1, "Test Changes"
      set :admin,   -2, "Administrative Changes"
      set :default, -3, "Nominal Changes"

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

    #
    def default
      set :major,    2, "Major Enhancements"
      set :minor,    1, "Minor Enhancements"
      set :bug,      0, "Bug Fixes"
      set :doc,     -1, "Documentation Changes"
      set :test,    -1, "Test Changes"
      set :admin,   -2, "Administrative Changes"
      set :default, -3, "Nominal Changes"

      # test files only changes
      on do |commit|
        if commit.files.all?{ |f| f.start_with?('test') }
          :test
        end
      end

    end

  end

end
