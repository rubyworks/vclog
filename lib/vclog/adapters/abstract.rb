module VCLog

  module Adapters

    require 'time'
    require 'pathname'
    require 'tempfile'

    require 'vclog/formatter'
    require 'vclog/changelog'
    require 'vclog/history'
    require 'vclog/change'
    require 'vclog/tag'

    # TODO: Might we have a NO-VCS changelog based on
    #       LOG: entries in source files?

    # TODO: maybe use Amp or SCM gem for future version.

    # Abstract base class for all version control system adapters.
    #
    class Abstract

      #
      attr :config

      # Root location.
      attr :root

      # Heuristics object.
      attr :heuristics

      # Minimum change level.
      attr :level

      #
      def initialize(repo)
        @repo = repo

        @root       = repo.root  
        @heuristics = repo.heuristics
        @level      = repo.level

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
      # TODO: possbile to move heuristics lookup into Change class?
      def changes
        #@changes ||= all_changes.select do |c|
        #  c.level >= self.level
        #end
        all_changes
      end

      #
      def all_changes
        @all_changes ||= (
          changes = []
          extract_changes.each do |change|
            #change.apply_heuristics(heuristics)
            changes << change 
          end
          changes
        )     
      end

      #
      def change_points
        @change_points ||= changes.map{ |c| c.points }.flatten
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
        list = all_changes.select{ |c| c.date <= date }
        list.sort_by{ |c| c.date }.last
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

=begin
    # Looks for a "[type]" indicator at the end of the commit message.
    # If that is not found, it looks at front of message for
    # "[type]" or "[type]:". Failing that it tries just "type:".
    #
    def split_type(note)
      note = note.strip
      if md = /\[(.*?)\]\Z/.match(note)
        t = md[1].strip.downcase
        n = note[0...(md.begin(0))]
      elsif md = /\A\[(.*?)\]\:?/.match(note)
        t = md[1].strip.downcase
        n = note[md.end(0)..-1]
      elsif md = /\A(\w+?)\:/.match(note)
        t = md[1].strip.downcase
        n = note[md.end(0)..-1]
      else
        n, t = note, nil
      end
      n.gsub!(/^\s*?\n/m,'') # remove blank lines
      return n, t
    end
=end

=begin
    # Write the ChangeLog to file.

    def write_changelog( log, file )
      if File.directory?(file)
        file = File.join( file, DEFAULT_CHANGELOG_FILE )
      end
      File.open(file,'w+'){ |f| f << log }
      puts "Change log written to #{file}."
    end

    # Write version stamp to file.

    def write_version( stamp, file )
      if File.directory?(file)
        file = File.join( file, DEFAULT_VERSION_FILE )
      end
      File.open(file,'w'){ |f| f << stamp }
      puts "#{file} saved."
    end

    # Format the version stamp.

    def format_version_stamp( version, status=nil, date=nil )
      if date.respond_to?(:strftime)
        date = date.strftime("%Y-%m-%d")
      else
        date = Time.now.strftime("%Y-%m-%d")
      end
      status = nil if status.to_s.strip.empty?
      stamp = []
      stamp << version
      stamp << status if status
      stamp << "(#{date})"
      stamp.join(' ')
    end
=end

    public

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

    end

  end

end

