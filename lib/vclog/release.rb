module VCLog

  # A Release encapsulate a collection of 
  # Change objects associated to a Tag.
  class Release

    # Tag object this release represents.
    attr :tag

    # Array of Change objects.
    attr :changes

    # New Release object.
    #
    # tag    - Tag object
    # change - Array of Change objects
    #
    def initialize(tag, changes)
      @tag = tag
      @changes = changes
    end

    # Group +changes+ by type and sort by level.
    # Returns an associative array of [type, changes].
    def groups
      @groups ||= (
        changes.group_by{ |e| e.label }.sort{ |a,b| b[1][0].level <=> a[1][0].level }
      )
    end

    # Compare release by tag.
    def <=>(other)
      @tag <=> other.tag
    end

    # Convert Release to Hash.
    def to_h
      { 'version'  => tag.name,
        'date'     => tag.date,
        'message'  => tag.message,
        'author'   => tag.author,
        'id'       => tag.id,
        'changes'  => changes.map{|change| change.to_h}
      }
    end

    #def to_json
    #  to_h.to_json
    #end
  end

end

