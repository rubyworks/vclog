require 'vclog/adapters/abstract'

module VCLog

  module Adapters

    # GIT Adapter.
    #
    class Git < Abstract

      # Fields and records are separated by control characters, which
      # don't turn up in commit messages or file names.
      FIELD  = "\x1f"
      RECORD = "\x1e"

      # Collect changes, i.e. commits.
      def extract_changes
        format = ['%ci', '%aN', '%H', '%s%n%n%b', ''].join('%x1f')
        output = git('log', '--name-only', "--pretty=format:%x1e#{format}")

        output.split(RECORD).reject{ |entry| entry.strip.empty? }.map do |entry|
          date, who, id, msg, files = entry.split(FIELD)
          Change.new(
            :id    => id,
            :date  => Time.parse(date),
            :who   => who,
            :msg   => msg.to_s.strip,
            :files => files.to_s.split("\n").reject{ |f| f.empty? }
          )
        end
      end

      # Collect tags. An annotated tag has its own author, date and
      # message; a lightweight tag takes them from its commit.
      def extract_tags
        format = %w[
          %(refname:short) %(objecttype) %(objectname) %(*objectname)
          %(taggername) %(taggeremail) %(taggerdate:iso8601) %(contents)
        ].join('%1f') + '%1e'

        output = git('for-each-ref', "--format=#{format}", 'refs/tags')

        list = []
        output.split(RECORD).each do |entry|
          name, type, id, commit_id, who, email, date, msg = entry.sub(/\A\n/, '').split(FIELD)
          next if name.nil? || name.empty?
          next unless version_tag?(name) # only version tags

          if type == 'tag'
            next if commit_id.to_s.empty? # a tag of something other than a commit
            change = Change.new(git_show(commit_id))
            list << Tag.new(
              :id     => change.id,
              :name   => name,
              :date   => date,
              :who    => "#{who} #{email}".strip,
              :msg    => msg.to_s.strip,
              :commit => change
            )
          elsif type == 'commit'
            info   = git_show(id)
            change = Change.new(info)
            list << Tag.new(
              :name   => name,
              :who    => info[:who],
              :date   => info[:date],
              :msg    => info[:message],
              :commit => change
            )
          end
        end
        list
      end

      # User name of developer.
      def user
        @user ||= git('config', 'user.name').strip
      end

      # Email address of developer.
      def email
        @email ||= git('config', 'user.email').strip
      end

      #
      def repository
        @repository ||= git('config', 'remote.origin.url').strip
      end

      #
      # Create a tag for the given commit reference.
      #
      def tag(ref, label, date, message)
        file = tempfile("message", message)
        date = date.strftime('%Y-%m-%d 23:59') unless String===date

        env = {'GIT_AUTHOR_DATE'=>date, 'GIT_COMMITTER_DATE'=>date}
        cmd = ['git', '-C', root.to_s, 'tag', '-a', '-F', file, label.to_s, ref.to_s]
        puts cmd.join(' ') if $DEBUG
        system(env, *cmd) unless $DRYRUN
      end

    private

      # Run git in the project's root and return what it prints.
      def git(*args)
        IO.popen(['git', '-C', root.to_s, *args], :err=>File::NULL, &:read).to_s
      end

      # Details of a single commit.
      def git_show(ref)
        format = ['%ci', '%cn', '%ce', '%H', '%s%n%n%b', ''].join('%x1f')
        entry  = git('show', '--name-only', "--pretty=format:#{format}", ref.to_s)

        date, who, email, id, msg, files = entry.split(FIELD)

        { :date    => Time.parse(date),
          :who     => "#{who} #{email}",
          :id      => id,
          :message => msg.to_s.strip,
          :files   => files.to_s.split("\n").reject{ |f| f.empty? } }
      end

    end

  end

end
