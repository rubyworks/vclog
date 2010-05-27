require 'vclog/adapters/abstract'

module VCLog
module Adapters

  # = GIT Adapter
  #
  class Git < Abstract

    #def initialize
    #end

    #
    #def changelog
    #  @changelog ||= ChangeLog.new(changes)
    #end

    #
    #def history(opts={})
    #  @history ||= History.new(self, opts)
    #end

    # Collect changes.
    #
    def extract_changes
      list = []
      changelog = `git log --pretty=format:"---%ci|~|%aN|~|%H|~|%s"`.strip
      changes = changelog.split("---")
      #changes = changelog.split(/^commit/m)
      changes.shift # throw the first (empty) entry away
      changes.each do |entry|
        date, who, rev, msg = entry.split('|~|')
        date = Time.parse(date)
        msg, type = *split_type(msg)
        list << [rev, date, who, msg, type]
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
        info = `git show #{tag}`
        md = /\Atag(.*?)\n(.*?)^commit/m.match(info)
        who, date, *msg = *md[2].split(/\n/)
        who  = who.split(':')[1].strip
        date = date[date.index(':')+1..-1].strip
        msg  = msg.join("\n")

        info = `git show #{tag}^ --pretty=format:"%ci|-|%H|-|"`
        date, rev, *_ = *info.split('|-|')

        #md = /\Atag(.*?)\n(.*?)^commit/m.match(info)
        #_who, _date, *_msg = *md[2].split(/\n/)
        #_who  = _who.split(':')[1].strip
        #_date = _date[_date.index(':')+1..-1].strip
        #_msg  = _msg.join("\n")

        list << [tag, rev, date, who, msg]
      end
      list
    end

  end#class Git

end
end

