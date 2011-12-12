require 'vclog/core_ext'
require 'vclog/change'

module VCLog

  # A ChangeLog encapsulates a list of Change objects.
  #
  class ChangeLog

    include Enumerable

    #DIR = File.dirname(__FILE__)

    #
    # Seconds in a day.
    #
    DAY = 24*60*60

    #
    # Array of Change or ChangePoint instances.
    #
    attr :changes

    #
    # Setup new ChangeLog instance.
    #
    # @param [Array<Change>] changes
    #   An array of Change objects.
    #
    def initialize(changes=nil)
      @changes = []
      @changes = changes if changes
    end

    #def changes=(changes)
    #  @changes = []
    #  changes.each do |change|
    #    case change
    #    when Change
    #      @changes << change
    #    else
    #      @changes << Change.new(change)
    #    end
    #  end
    #end

    # Add a change entry to the log.
    def change(data={})
      @changes << Change.new(data)
    end

    #
    # Sort changes in place.
    #
    def sort!(&block)
      changes.sort!(&block)
    end

    #
    # Iterate over each change.
    #
    def each(&block)
      changes.each(&block)
    end

    #
    # Is the changelog void of any changes?
    #
    def empty?
      changes.empty?
    end

    #
    # Return the number of changes in the changelog.
    #
    def size
      changes.size
    end

    #
    # And a change to the changelog.
    #
    def <<(entry)
      case entry
      when Change, ChangePoint
        @changes << entry
      else
        #raise "Not a Change ro ChangePoint instance - #{entry.inspect}"
      end
    end

    #
    # Return a new changelog with entries having a level higer or
    # equal to the given level.
    #
    def above(level)
      above = changes.select{ |entry| entry.level >= level }
      self.class.new(above)
    end

    #
    # Return a new changelog with entries occuring after the
    # given date limit.
    #
    def after(date_limit)
      after = changes.select{ |entry| entry.date > date_limit + DAY }
      self.class.new(after)
    end

    #
    # Return a new changelog with entries occuring before the
    # given date limit.
    #
    def before(date_limit)
      before = changes.select{ |entry| entry.date <= date_limit + DAY }
      self.class.new(before)
    end

    # Return a new changelog with entries that have a specified type.
    # TODO: Be able to specify which types to include or omit.
    #def typed
    #  self.class.new(changes.select{ |e| e.type })
    #end

    #
    def by_type
      mapped = {}
      changes.each do |entry|
        mapped[entry.type] ||= self.class.new
        mapped[entry.type] << entry
      end
      mapped
    end

    #
    def by_author
      mapped = {}
      changes.each do |entry|
        mapped[entry.author] ||= self.class.new
        mapped[entry.author] << entry
      end
      mapped
    end

    #
    def by_date
      mapped = {}
      changes.each do |entry|
        mapped[entry.date.strftime('%Y-%m-%d')] ||= self.class.new
        mapped[entry.date.strftime('%Y-%m-%d')] << entry
      end
      mapped = mapped.to_a.sort{ |a,b| b[0] <=> a[0] }
      mapped
    end

    #
    #def by_date
    #  mapped = {}
    #  changes.each do |entry|
    #    mapped[entry.date.strftime('%Y-%m-%d')] ||= self.class.new
    #    mapped[entry.date.strftime('%Y-%m-%d')] << entry
    #  end
    #  mapped
    #end

    #
    # Convert to list of hash.
    #
    # @return [Array<Hash>]
    #
    # @todo Not a Hash! Need to rename method.
    #
    def to_h
      map{ |change| change.to_h }
    end

  end

end



# TODO: THIS IS HERE AS A REMINDER ABOUT TEH XSL TEMPLATE.
#       WHAT TO DO WITH IT?

=begin
    ###################
    # Save Chaqngelog #
    ###################

    # Save changelog as file in specified format.
    def save(file, format=:gnu, *args)
      case format.to_sym
      when :xml
        text = to_xml
#save_xsl(file)
      when :html
        text = to_html(*args)
      when :rel
        text = to_rel(file, *args)
      when :yaml
        text = to_yaml(file)
      when :json
        text = to_json(file)
      else
        text = to_gnu
      end

      FileUtils.mkdir_p(File.dirname(file))

      different = true
      if File.exist?(file)
        different = (File.read(file) != text)
      end

      File.open(file, 'w') do |f|
        f << text
      end if different
    end

    #
    def save_xsl(file)
      #xslfile = file.chomp(File.extname(file)) + '.xsl'
      xslfile = File.join(File.dirname(file), 'log.xsl')
      unless File.exist?(xslfile)
        FileUtils.mkdir_p(File.dirname(xslfile))
        File.open(xslfile, 'w') do |f|
          f << DEFAULT_LOG_XSL
        end
      end
    end
=end

