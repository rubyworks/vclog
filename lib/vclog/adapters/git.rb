require 'vclog/adapters/abstract'

module VCLog
module Adapters

  # = GIT Adapter
  #
  class Git < Abstract

    # Collect changes.
    #
    def extract_changes
      list = []
      changelog = `git log --pretty=format:"\036|||%ci|~|%aN|~|%H|~|%s"`.strip
      changes = changelog.split("\036|||")
      #changes = changelog.split(/^commit/m)
      changes.shift # throw the first (empty) entry away
      changes.each do |entry|
        date, who, rev, msg = entry.split('|~|')
        date = Time.parse(date)
        list << [rev, date, who, msg]
      end
      list
    end

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
              who  = $'
            when /^Date:/
              date = $'
            else
              msg << line
            end
          end
          msg = msg.strip
          info = `git show #{tag}^ --pretty=format:"%ci|~|%H|~|"`
          date, rev, *_ = *info.split('|~|')
        else
          info = `git show #{tag} --pretty=format:"%cn|~|%ce|~|%ci|~|%H|~|%s|~|"`
          who, email, date, rev, msg, *_ = *info.split('|~|')
          who = who + ' ' + email
        end          

        #if $DEBUG
        #  p who, date, rev, msg
        #  puts
        #end

        list << [tag, rev, date, who, msg]
      end
      list
    end

    #
    def user
      @user ||= `git config user.name`.strip
    end

    #
    def email
      @email ||= `git config user.email`.strip
    end

    #
    def repository
      @repository ||= `git config remote.origin.url`.strip
    end

  end#class Git

end
end

