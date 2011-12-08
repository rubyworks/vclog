require 'vclog/adapters/abstract'

module VCLog
module Adapters

  # The GIT Adapter utilizes the +grit+ gem.
  #
  class Git < Abstract

    GIT_COMMIT_MARKER = '=====%n'
    GIT_FIELD_MARKER  = '-----%n'

    RUBY_COMMIT_MARKER = "=====\n"
    RUBY_FIELD_MARKER  = "-----\n"

    # TODO: in the future we might use grit, if it improves enough.
    def initialize_framework
      #require 'grit'
    end

    #
    def grit_repo
      @grit_repo ||= Grit::Repo.new(root)
    end

    # Collect changes.
    #
    def extract_changes
      list = []
      changelog = `git log --pretty=format:"\036|||%ci|~|%aN|~|%H|~|%s"`.strip

      command = 'git log --name-only --pretty=format:"' +
                  GIT_COMMIT_MARKER +
                  '%ci' +
                  GIT_FIELD_MARKER +
                  '%aN' +
                  GIT_FIELD_MARKER +
                  '%H' +
                  GIT_FIELD_MARKER +
                  '%s' +
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
      list
    end  

    #
    #def extract_files(change_list)
    #  change_list.each do |change|
    #    files = `git show --pretty="format:" --name-only #{c.id}`
    #    files = files.split("\n")
    #    change.files = files
    #  end
    #end

    # TODO
    #def extract_changes
    #  repo.commit.map do |commit|
    #    [commit.id, commit.date, commit.author.to_s, commit.message]
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
    def extract_tags
      list = []
      tags = `git tag -l`
      tags.split(/\s+/).each do |tag|
        next unless version_tag?(tag) # only version tags
        who, date, rev, msg = nil, nil, nil, nil
        info = `git show #{tag}`
        info, *_ = info.split(/^(commit|diff|----)/)
        if /\Atag/ =~ info
          msg = ''
          info.lines.to_a[1..-1].each do |line|
            case line
            when /^Tagger:/
              who  = $'.strip
            when /^Date:/
              date = $'.strip
            else
              msg << line
            end
          end
          msg = msg.strip
          info = `git show #{tag}^ --pretty=format:"%ci|~|%H|~|"`
          cdate, id, *_ = *info.split('|~|')
        else
          info = `git show #{tag} --pretty=format:"%cn|~|%ce|~|%ci|~|%H|~|%s|~|"`
          who, email, cdate, id, msg, *_ = *info.split('|~|')
          who  = who + ' ' + email
          date = cdate
        end          

        #if $DEBUG
        #  p who, date, rev, msg
        #  puts
        #end

        list << Tag.new(:name=>tag, :date=>date, :who=>who, :msg=>msg, :commit_id=>id, :commit_date=>cdate)
      end
      list
    end

    # TODO: grit doesn't provide the tag information.
    #def extract_tags
    #  list = grit_repo.tags.map do |tag|
    #    [tag.name, tag.commit.id, tag.commit.committed_date, tag.commit.author.to_s, tag.commit.message]
    #  end
    #  list
    #end

    #
    def user
      #@user ||= grit_repo.config['user.name']
      @user ||= `git config user.name`.strip
    end

    #
    def email
      #@email ||= grit_repo.config['user.email']
      @email ||= `git config user.email`.strip
    end

    #
    def repository
      #@repository ||= grit_repo.config['remote.origin.url']
      @repository ||= `git config remote.origin.url`.strip
    end

    # Create a tag for the given commit reference.
    def tag(ref, label, date, message)
      file = tempfile("message", message)
      date = date.strftime('%Y-%m-%d 23:59') unless String===date

      cmd = %[GIT_AUTHOR_DATE='#{date}' GIT_COMMITTER_DATE='#{date}' git tag -a -F '#{file}' #{label} #{ref}]
      puts cmd if $DEBUG
      `#{cmd}` unless $DRYRUN
    end

  end#class Git

end
end
