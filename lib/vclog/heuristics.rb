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
    def apply(commit)
      type = nil

      @rules.find{ |rule| type = rule.call(commit) }

      # a degree of backwards compatibility
      commit.type ||= type if Symbol === type

      if commit.type
        if @labels.key?(commit.type)
          commit.label = @labels[commit.type].label
          commit.level = @labels[commit.type].level
        else
          commit.level = 0
          commit.label = "#{commit.type.to_s.capitalize} Enhancements"
        end
      else
        default = @labels[:default]
        if default
          commit.level = default.level
          commit.label = default.label
        else
          commit.level = 0
          commit.label = 'Nominal Changes'
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

      on /\A(\w+):/ do |commit, md|
        commit.type = md[1].to_sym
        commit.message = commit.message.sub(md[0],'').strip
        true
      end

      on /\[(\w+)\]\s*$/ do |commit, md|
        commit.type = md[1].to_sym
        commit.message = commit.message.sub(md[0],'').strip
        true
      end

      on /updated? (README|PROFILE|PACKAGE|VERSION|MANIFEST)/ do |commit|
        commit.type = :admin
      end

      on /(bump|bumped|prepare) version/ do |commit|
        commit.type = :admin
      end
    end

    # Work on next-gem default heuristics.
    def default2
      set :major,    3, "Major Enhancements"
      set :minor,    2, "Minor Enhancements"
      set :bug,      1, "Bug Fixes"
      set :default,  0, "Nominal Changes"
      set :doc,     -1, "Documentation Changes"
      set :test,    -2, "Test/Spec Adjustments"
      set :admin,   -3, "Administrative Changes"

      # test/spec file only changes
      on do |commit|
        if commit.files.all?{ |f| f.start_with?('test') || f.start_with?('spec') }
          commit.type = :test
        end
      end

    end

  end

end
