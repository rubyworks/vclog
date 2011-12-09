require 'vclog/adapters/abstract'

module VCLog

  module Adapters

    # Mercurial Adapter
    #
    class Hg < Abstract

      # Collect changes.
      def extract_changes
        list = []
        changelog = `hg log -v`.strip
        changes = changelog.split("\n\n\n")
        changes.each do |entry|
          settings = parse_entry(entry)
          list << Change.new(settings)
        end
        list
      end

      # Collect tags.
      def extract_tags
        list = []
        if File.exist?('.hgtags')
          File.readlines('.hgtags').each do |line|
            rev, tag = line.strip.split(' ')
            entry = `hg log -v -r #{rev}`.strip
            settings = parse_entry(entry)
            settings[:name] = tag
            list << Tag.new(settings)
          end
        end
        list
      end

      # TODO: check .hgrc for user and email.

      #
      def user
        ENV['HGUSER'] || ENV['USER']
      end

      #
      def email
        ENV['HGEMAIL'] || ENV['EMAIL']
      end

      #
      def repository
        @repository ||= `hg showconfig paths.default`.strip
      end

      #
      def uuid
        nil
      end

      # TODO: Will multi-line messages work okay this way?
      def tag(ref, label, date, msg)
        file = tempfile("message", msg)
        date = date.strftime('%Y-%m-%d') unless String===date

        cmd  = %[hg tag -r #{ref} -d #{date} -m "$(cat #{file})" #{label}]

        puts cmd if $DEBUG
        `#{cmd}` unless $DRYRUN
      end

     private

      # Parse log entry.
      def parse_entry(entry)
        settings = {}

        entry.strip!

        if md = /^changeset:(.*?)$/.match(entry)
          settings[:id] = md[1].strip
        end

        if md = /^date:(.*?)$/.match(entry)
          settings[:date] = Time.parse(md[1].strip)
        end

        if md = /^user:(.*?)$/.match(entry)
          settings[:who] = md[1].strip
        end

        if md = /^files:(.*?)$/.match(entry)
          settings[:files] = md[1].strip.split(' ')
        end

        if md = /^description:(.*?)\Z/m.match(entry)
          settings[:msg] = md[1].strip
        end

        return settings
      end

    end

  end

end
