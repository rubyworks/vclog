require 'vclog/adapters/abstract'

module VCLog

  module Adapters

    # GIT Adapter.
    #
    class Git < Abstract

      GIT_COMMIT_MARKER = '=====%n'
      GIT_FIELD_MARKER  = '-----%n'

      RUBY_COMMIT_MARKER = "=====\n"
      RUBY_FIELD_MARKER  = "-----\n"

      # Collect changes, i.e. commits.
      def extract_changes
        list = []

        command = 'git log --name-only --pretty=format:"' +
                    GIT_COMMIT_MARKER +
                    '%ci' +
                    GIT_FIELD_MARKER +
                    '%aN' +
                    GIT_FIELD_MARKER +
                    '%H' +
                    GIT_FIELD_MARKER +
                    '%s%n%n%b' +
                    GIT_FIELD_MARKER +
                    '"'

        changes = `#{command}`.split(RUBY_COMMIT_MARKER)

        changes.shift # throw the first (empty) entry away

        changes.each do |entry|
          date, who, id, msg, files = entry.split(RUBY_FIELD_MARKER)
          date  = Time.parse(date)
          files = files.split("\n")
          list << Change.new(:id=>id, :date=>date, :who=>who, :msg=>msg, :files=>files)
        end

        return list
      end  

      #
      #def extract_files(change_list)
      #  change_list.each do |change|
      #    files = `git show --pretty="format:" --name-only #{c.id}`
      #    files = files.split("\n")
      #    change.files = files
      #  end
      #end

      # Collect tags.
      #
      # `git show 1.0` produces:
      #
      #   tag 1.0
      #   Tagger: 7rans <transfire@gmail.com>
      #   Date:   Sun Oct 25 09:27:58 2009 -0400
      #
      #   version 1.0
      #   commit
      #   ...
      #
      # @todo This code is pretty poor, but it suffices for now.
      #       And we need not worry about it the future b/c eventually
      #       we will replace it by using the `amp` or `scm` gem.
      def extract_tags
        list = []
        tags = `git tag -l`
        tags.split(/\s+/).each do |tag|
          next unless version_tag?(tag) # only version tags
          id, who, date, rev, msg = nil, nil, nil, nil, nil
          info = `git show #{tag}`
          info, *_ = info.split(/^(commit|diff|----)/)
          if /\Atag/ =~ info
            msg = ''
            info.lines.to_a[1..-1].each do |line|
              case line
              when /^Tagger:/
                who = $'.strip
              when /^Date:/
                date = $'.strip
              when /^\s*[a-f0-9]+/
                id = $0.strip
              else
                msg << line
              end
            end
            msg = msg.strip

            #info = `git show #{tag}^ --pretty=format:"%ci|~|%H|~|"`
            #cdate, id, *_ = *info.split('|~|')

            info = git_show("#{tag}")

            change = Change.new(info)

            list << Tag.new(:id=>change.id, :name=>tag, :date=>date, :who=>who, :msg=>msg, :commit=>change)
          else
            #info = `git show #{tag} --pretty=format:"%cn|~|%ce|~|%ci|~|%H|~|%s|~|"`
            info   = git_show(tag)
            change = Change.new(info)

            tag_info = {
              :name   => tag,
              :who    => info[:who],
              :date   => info[:date],
              :msg    => info[:message],
              :commit => change
            }
            list << Tag.new(tag_info)
          end          

          #if $DEBUG
          #  p who, date, rev, msg
          #  puts
          #end

          #list << tag
        end

        return list
      end

      # User name of developer.
      def user
        @user ||= `git config user.name`.strip
      end

      # Email address of developer.
      def email
        @email ||= `git config user.email`.strip
      end

      #
      def repository
        @repository ||= `git config remote.origin.url`.strip
      end

      #
      # Create a tag for the given commit reference.
      #
      def tag(ref, label, date, message)
        file = tempfile("message", message)
        date = date.strftime('%Y-%m-%d 23:59') unless String===date

        cmd = %[GIT_AUTHOR_DATE='#{date}' GIT_COMMITTER_DATE='#{date}' git tag -a -F '#{file}' #{label} #{ref}]
        puts cmd if $DEBUG
        `#{cmd}` unless $DRYRUN
      end

    private

      #
      #
      #
      def git_show(ref)
        command = 'git show ' + ref.to_s + ' --name-only --pretty=format:"' +
                    '%ci' +
                    GIT_FIELD_MARKER +
                    '%cn' +
                    GIT_FIELD_MARKER +
                    '%ce' +
                    GIT_FIELD_MARKER +
                    '%H' +
                    GIT_FIELD_MARKER +
                    '%s%n%n%b' +
                    GIT_FIELD_MARKER +
                    '"'

        entry = `#{command}`

        date, who, email, id, msg, files = entry.split(RUBY_FIELD_MARKER)

        who = who + ' ' + email
        date  = Time.parse(date)
        files = files.split("\n")

        return { :date=>date, :who=>who, :id=>id, :message=>msg, :files=>files }
      end

    end

  end

end
