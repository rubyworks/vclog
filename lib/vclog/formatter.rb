require 'ostruct'
#require 'ansi'

module VCLog

  #
  class Formatter

    DIR = File.dirname(__FILE__)

    #
    attr :vcs

    # New Formmater.
    #
    # vcs - an instance of a subclass of VCS::Abstract
    #
    def initialize(vcs)
      @vcs = vcs
    end

    # Returns a Changelog object taken from the VCS.
    def changelog
      @vcs.changelog
    end

    # Returns a History object garnered form the VCS.
    def history
      @vcs.history
    end

    #
    def user
      @options.user || @vcs.user
    end

    #
    def email
      @options.email || @vcs.email
    end

    #
    def repository
      @vcs.repository
    end

    # TODO
    def url
      @options.url || @vcs.repository
    end

    # TODO
    def homepage
      @options.homepage
    end

    # TODO: let be nil and let template make a default if wanted
    def title
      return @options.title if @options.title
      case @doctype
      when :history
        "RELEASE HISTORY"
      else
        "CHANGELOG"
      end
    end

    #
    #--
    # NOTE: ERBs trim_mode is broken --it removes an extra space. 
    # So we can't use it for plain text templates.
    #++
    def display(doctype, format, options)
      options = OpenStruct.new(options) if Hash === options

      @doctype = doctype
      @format  = format
      @options = options

      require_formatter(format)

      tmp_file = Dir[File.join(DIR, 'templates', "#{@doctype}.#{@format}.{erb,rb}")].first

      tmp = File.read(tmp_file)

      case File.extname(tmp_file)
      when '.rb'
        eval(tmp, binding)
      when '.erb'
        erb = ERB.new(tmp, nil, '<>')
        erb.result(binding)
      else
        raise "unrecognized template - #{tmp_file}"
      end
    end

    private

      #
      def require_formatter(format)
        case format.to_s
        when 'yaml'
          require 'yaml'
        when 'json'
          require 'json'
        end
      end

      #
      def h(input)
         result = input.to_s.dup
         result.gsub!("&", "&amp;")
         result.gsub!("<", "&lt;")
         result.gsub!(">", "&gt;")
         result.gsub!("'", "&apos;")
         #result.gsub!("@", "&at;")
         result.gsub!("\"", "&quot;")
         return result
      end

  end

end
