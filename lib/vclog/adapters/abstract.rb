module VCLog

  module Adapters

    require 'time'
    require 'pathname'
    require 'tempfile'

    require 'vclog/changelog'
    require 'vclog/change'
    require 'vclog/tag'

    # TODO: Could we support a "no scm" changelog based on `LOG:` entries in source files?

    # TODO: Possibly use Amp or SCM gem for future version.

    # Abstract base class for all version control system adapters.
    #
    class Abstract

      #
      attr :config

      # Root location.
      attr :root

      # Heuristics object.
      attr :heuristics

      #
      def initialize(repo)
        @repo       = repo
        @root       = repo.root  
        @heuristics = repo.heuristics

        initialize_framework
      end

      # This is used if the adapter is using an external library
      # to interface with the repository.
      def initialize_framework
      end

      #
      def extract_tags
        raise "Not Implemented"
      end

      #
      def extract_changes
        raise "Not Implemented"
      end

      #
      def tags
        @tags ||= extract_tags
      end  

      #
      def changes
        @changes ||= extract_changes
      end

      #
      def change_points
        @change_points ||= (
          changes.inject([]){ |list, change| list.concat(change.points); list }
        )
      end

      #
      def tag?(name)
        tags.find{ |t| t.name == name }
      end

      # Returns the current verion string.
      def version
        if tags.last
          v = tags[-1].name # TODO: ensure the latest version
          v = tags[-2].name if v == 'HEAD'
        else
          v = '0.0.0'
        end
        return v
      end

      # Return the latest commit as of a given date.
      def change_by_date(date)
        list = changes.select{ |c| c.date <= date }
        list.sort_by{ |c| c.date }.last
      end

      #
      def user
        ENV['USER']
      end

      #
      def email
        ENV['EMAIL']
      end

      #
      def repository
        nil
      end

      #
      def uuid
        nil
      end

    private

      #
      def version_tag?(tag_name)
        /(v|\d)/i =~ tag_name
      end

      #
      def tempfile(name, content)
        mfile = Tempfile.new(name)
        File.open(mfile.path, 'w'){ |f| f << content }
        mfile.path
      end

    end

  end

end

