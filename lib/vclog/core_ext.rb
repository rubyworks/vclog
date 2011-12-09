require 'facets/string/fold'
require 'facets/string/indent'
require 'facets/string/tabto'
require 'facets/string/margin'
require 'facets/enumerable/group_by'
require 'facets/kernel/ask'

=begin

module VCLog

  # Extensions for String class.
  # Taken from Facets.
  module String

    # Provides a margin controlled string.
    #
    #   x = %Q{
    #         | This
    #         |   is
    #         |     margin controlled!
    #         }.margin
    #
    #
    #   NOTE: This may still need a bit of tweaking.
    #
    #  CREDIT: Trans

    def margin(n=0)
      #d = /\A.*\n\s*(.)/.match( self )[1]
      #d = /\A\s*(.)/.match( self)[1] unless d
      d = ((/\A.*\n\s*(.)/.match(self)) ||
          (/\A\s*(.)/.match(self)))[1]
      return '' unless d
      if n == 0
        gsub(/\n\s*\Z/,'').gsub(/^\s*[#{d}]/, '')
      else
        gsub(/\n\s*\Z/,'').gsub(/^\s*[#{d}]/, ' ' * n)
      end
    end

    # Preserves relative tabbing.
    # The first non-empty line ends up with n spaces before nonspace.
    #
    #  CREDIT: Gavin Sinclair

    def tabto(n)
      if self =~ /^( *)\S/
        indent(n - $1.length)
      else
        self
      end
    end

    # Indent left or right by n spaces.
    # (This used to be called #tab and aliased as #indent.)
    #
    #  CREDIT: Gavin Sinclair
    #  CREDIT: Trans

    def indent(n)
      if n >= 0
        gsub(/^/, ' ' * n)
      else
        gsub(/^ {0,#{-n}}/, "")
      end
    end

  end

end

class String #:nodoc:
  include VCLog::String
end


# Core extension

module Enumerable

  unless defined?(group_by) or defined?(::ActiveSupport)  # 1.9 or ActiveSupport

    # #group_by is used to group items in a collection by something they
    # have in common.  The common factor is the key in the resulting hash, the
    # array of like elements is the value.
    #
    #   (1..5).group_by { |n| n % 3 }
    #        #=> { 0 => [3], 1 => [1, 4], 2 => [2,5] }
    #
    #   ["I had", 1, "dollar and", 50, "cents"].group_by { |e| e.class }
    #        #=> { String => ["I had","dollar and","cents"], Fixnum => [1,50] }
    #
    # CREDIT: Erik Veenstra

    def group_by #:yield:
      #h = k = e = nil
      r = Hash.new
      each{ |e| (r[yield(e)] ||= []) << e }
      r
    end

  end

end

=end

