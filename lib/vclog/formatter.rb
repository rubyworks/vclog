require 'ostruct'
#require 'ansi'

module VCLog

  # The formatter class acts a a controller for outputing 
  # change log / release history.
  #
  class Formatter

    # Directory of this file, so as to locate templates.
    DIR = File.dirname(__FILE__)

    # Instance of VCLog::Repo.
    attr :repo

    # New Formmater.
    #
    # repo - instance of VCLog::Repo
    #
    def initialize(repo)
      @repo = repo
    end

    # Returns a Changelog object taken from the VCS.
    def changelog
      @repo.changelog
    end

    # Returns a History object garnered from the VCS.
    def history
      @repo.history
    end

    #
    def user
      @options.user || @repo.user
    end

    #
    def email
      @options.email || @repo.email
    end

    #
    def repository
      @repo.repository
    end

    # TODO
    def url
      @options.url || @repo.repository
    end

    # TODO
    def homepage
      @options.homepage
    end

    # TODO: Let the title be nil and the template can set a default if it needs to.

    #
    def title
      return @options.title if @options.title
      case @doctype
      when :history
        "RELEASE HISTORY"
      else
        "CHANGELOG"
      end
    end

    # NOTE: ERBs trim_mode is broken --it removes an extra space. 
    # So we can't use it for plain text templates.

    #
    #
    def report(options)
      doctype = options.delete(:report) || 'changelog'
      format  = options.delete(:format) || 'ansi'

      options = OpenStruct.new(options) if Hash === options

      @doctype = doctype
      @format  = format
      @options = options

      require_formatter(format)

      tmp_file = Dir[File.join(DIR, 'templates', "#{@doctype}.#{@format}.{erb,rb}")].first

      tmp = File.read(tmp_file)

      case File.extname(tmp_file)
      when '.rb'
        eval(tmp, binding, tmp_file)
      when '.erb'
        erb = ERB.new(tmp, nil, '<>')
        erb.result(binding)
      else
        raise "unrecognized template - #{tmp_file}"
      end
    end

   private

    # Depending on the format special libraries may by required.
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
