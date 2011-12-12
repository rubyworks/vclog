require 'ostruct'
#require 'ansi'
require 'erb'

module VCLog

  # The Report class acts a controller for outputing 
  # change log / release history.
  #
  class Report

    #
    # Directory of this file, so as to locate templates.
    #
    DIR = File.dirname(__FILE__)

    #
    # Instance of VCLog::Repo.
    #
    attr :repo

    #
    # OpenStruct of report options.
    #
    attr :options

    #
    # Setup new Reporter instance.
    #
    # @param [Repo] repo
    #   An instance of VCLog::Repo.
    #
    def initialize(repo, options)
      @repo    = repo
      @options = case options 
                 when Hash
                   OpenStruct.new(options)
                 else
                   options
                 end

      @options.level ||= 0
    end

    #
    # Returns a Changelog object.
    #
    def changelog
      changes = options.point ? repo.changes : repo.change_points
      ChangeLog.new(changes).above(options.level)
    end

    #
    # Compute and return set of releases for +changelog+ changes.
    #
    def releases
      repo.releases(changelog.changes)
    end

    #
    # User as given by the command line or from the repo.
    #
    def user
      options.user || repo.user
    end

    #
    # Email address as given on the command line or from the repo.
    #
    def email
      options.email || repo.email
    end

    #
    # Repo repository URL.
    #
    def repository
      repo.repository
    end

    #
    # Repository URL.
    #
    # @todo Ensure this is being provided.
    #
    def url
      options.url || repo.repository
    end

    # TODO
    def homepage
      options.homepage
    end

    # TODO: Let the title be nil and the template can set a default if it needs to.

    #
    # Report title.
    #
    def title
      return options.title if options.title
      case options.type
      when :history
        "RELEASE HISTORY"
      else
        "CHANGELOG"
      end
    end

    # NOTE: ERBs trim_mode is broken --it removes an extra space. 
    # So we can't use it for plain text templates.

    #
    # Print report.
    #
    def print
      options.type   ||= 'changelog'
      options.format ||= 'ansi'

      require_formatter(options.format)

      tmp_file = Dir[File.join(DIR, 'templates', "#{options.type}.#{options.format}.{erb,rb}")].first

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

    #
    # Depending on the format special libraries may by required.
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
    # HTML escape.
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

    #
    # Convert from RDoc to HTML.
    #
    def r(input)
      rdoc.convert(input)
    end

    #
    # RDoc converter.
    #
    # @return [RDoc::Markup::ToHtml] rdoc markup HTML converter.
    #
    def rdoc
      @_rdoc ||= (
        gem 'rdoc' rescue nil  # to ensure latest version
        require 'rdoc'
        RDoc::Markup::ToHtml.new
      )
    end

  end

end
