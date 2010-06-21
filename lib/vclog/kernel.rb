module VCLog

  module Kernel

    #
    def heuristics
      @heuristics ||= Heuristics.new()
    end

  end

end
