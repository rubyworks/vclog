module VCLog

  #
  class Release
    attr :tag
    attr :changes
    #
    def initialize(tag, changes)
      @tag = tag
      @changes = changes
    end

    def to_h
      { :tag => tag.to_h, :changes => changes }
    end

    def to_json
      to_h.to_json
    end
  end

end

