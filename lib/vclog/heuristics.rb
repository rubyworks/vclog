module VCLog

  # TODO: Develop heuristics for determining the nature
  # of changes from the commit messages. Ultimately allow
  # user to customize heuristics per project.
  module Heuristics

    def explicit_tag(message)
      md = /^(\w+)\:/.match(message)
      md ? {:tag => md[1]} : {}
    end

  end

end
