require 'ostruct'
require 'erb'
#require 'ansi'

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
      @repo = repo

      options[:type]   ||= 'changelog'
      options[:format] ||= 'ansi'

      @options = OpenStruct.new(options)

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
    # Report type.
    #
    def type
      options.type
    end

    #
    # Report format.
    #
    def format
      options.format
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
      case type
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
      require_formatter(format)

      tmpl_glob = File.join(DIR, 'templates', "#{type}.#{format}.{erb,rb}")
      tmpl_file = Dir[tmpl_glob].first

      raise "could not find template -- #{tmpl_glob}" unless tmpl_file

      tmpl = File.read(tmpl_file)

      case File.extname(tmpl_file)
      when '.rb'
        eval(tmpl, binding, tmpl_file)
      when '.erb'
        erb = ERB.new(tmpl, nil, '<>')
        erb.result(binding)
      else
        raise "unrecognized template type -- #{tmpl_file}"
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
