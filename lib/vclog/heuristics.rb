require 'vclog/heuristics/type'
require 'vclog/heuristics/rule'

module VCLog

  # Heuristics stores a set of rules to be applied to commmits
  # in order to assign them priority levels and report labels.
  #
  class Heuristics

    # Load heuristics from a designated file.
    #
    # @param [String] file 
    #   Configuration file.
    #
    def self.load(file)
      raise LoadError unless File.exist?(file)
      new{ instance_eval(File.read(file), file) }
    end

    # Setup new heurtistics set.
    def initialize(&block)
      @rules = []

      @types = Hash.new{ |h,k| h[k] = h[:default] }
      @types[:default] = Type.new(:default, -1, "Nominal Changes")

      @colors = [:red, :red, :yellow, :green, :cyan, :blue, :blue]

      if block
        instance_eval(&block)
      else
        default
      end
    end

    # Apply heuristics to a commit.
    #
    # @param [Change] commit
    #   Instance of Change encapsulates an SCM commit.
    #
    def apply(commit)
      # apply rules, breaking on first rule found that fits.
      @rules.find{ |rule| rule.call(commit) }

      unless commit.level
        commit.level = types[commit.type].level
      end

      unless commit.label
        commit.label = types[commit.type].label
      end

      # apply color for commit level
      color = @colors[commit.level + (@colors.size / 2)]
      color ||= (commit.level > 0 ? @colors.first : @colors.last)
      commit.color = color
    end

    # Define a new rule.
    def on(pattern=nil, &block)
      @rules << Rule.new(pattern, &block)
    end

    # Convenience method for setting-up commit types, which can
    # be easily assigned, setting both label and level in one go.
    def type(type, level, label)
      @types[type.to_sym] = Type.new(type, level, label)
    end

    # @deprecated
    alias_method :set, :type

    # Access to defined types.
    #
    # @example
    #   commit.type = :major
    #
    attr :types

    # Set color list. The center element cooresponds to `level=0`.
    # Elements before the center are incrementally higher levels
    # and those after are lower.
    #
    # @example
    #   colors :red, :yellow, :green, :cyan, :blue
    #
    def colors(*list)
      @colors = list.reverse
    end

    # Default settings.
    def default
      type :major,    3, "Major Enhancements"
      type :minor,    2, "Minor Enhancements"
      type :bug,      1, "Bug Fixes"
      type :default,  0, "Nominal Changes"
      type :doc,     -1, "Documentation Changes"
      type :test,    -2, "Test/Spec Adjustments"
      type :admin,   -3, "Administrative Changes"

      on /\A(\w+):/ do |commit, md|
        type = md[1].to_sym
        commit.type    = type
        commit.message = commit.message.sub(md[0],'').strip
        true
      end

      on /\[(\w+)\]\s*$/ do |commit, md|
        type = md[1].to_sym
        commit.type    = type
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

    # Work on next-gen default heuristics.
    def default2
      type :major,    3, "Major Enhancements"
      type :minor,    2, "Minor Enhancements"
      type :bug,      1, "Bug Fixes"
      type :default,  0, "Nominal Changes"
      type :doc,     -1, "Documentation Changes"
      type :test,    -2, "Test/Spec Adjustments"
      type :admin,   -3, "Administrative Changes"

      # test/spec file only changes
      on do |commit|
        if commit.files.all?{ |f| f.start_with?('test') || f.start_with?('spec') }
          commit.type = :test
        end
      end
    end

   private

    # TODO: applies types that are "close", to help overlook typos.
    #
    #def close_type(type)
    #  case type.to_s
    #  when 'maj', 'major' then :major
    #  when 'min', 'minor' then :minor
    #  when 'bug'          then :bug
    #  when ''             then :other
    #  else
    #    type.to_sym
    #  end
    #end

  end

end
