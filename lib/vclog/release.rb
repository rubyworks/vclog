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
      { 'version'  => tag.name,
        'date'     => tag.date,
        'message'  => tag.message,
        'author'   => tag.author,
        'revision' => tag.revision,
        'changes'  => changes.map{|change| change.to_h}
      }
    end

    # Group +changes+ by type.
    def groups
      @groups ||= changes.group_by{ |e| e.type }
    end

    #def to_json
    #  to_h.to_json
    #end

    def <=>(other)
      @tag <=> other.tag
    end
  end

end

