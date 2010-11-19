require 'vclog/adapters'
require 'vclog/heuristics'
require 'vclog/history_file'

module VCLog

  #
  class Repo
    # Remove some undeeded methods to make way for delegation to scm adapter.
    %w{display}.each{ |name| undef_method(name) }

    # File glob used to find project root directory.
    ROOT_GLOB = '{.vclog/,.config/vclog/,config/vclog/,.git/,.hg/,_darcs/,README*}/'

    # File glob used to find the vclog configuration directory.
    CONFIG_GLOB = '{.vclog,.config/vclog,config/vclog}/'

    # Project's root directory.
    attr :root

    #
    attr :options

    # Default change level.
    # TODO: get from config file?
    attr :level

    #
    def initialize(root, options={})
      @root    = root || lookup_root
      @options = options

      @config_directory = Dir[File.join(@root, CONFIG_GLOB)]

      @level = (options[:level] || 0).to_i

      type = read_type
      raise ArgumentError, "Not a recognized version control system." unless type

      @adapter = Adapters.const_get(type.capitalize).new(self)
    end

    #
    def adapter
      @adapter
    end

    #
    def config_directory
      @config_directory
    end

    #
    def force?
      options[:force]
    end

    #
    def read_type
      dir = nil
      Dir.chdir(root) do
        dir = Dir.glob("{.svn,.git,.hg,_darcs}").first
      end
      dir[1..-1] if dir
    end

    # Find project root. This searches up from the current working
    # directory for the following paths (in order):
    #
    #   .vclog/
    #   .config/vclog/
    #   config/vclog/
    #   .git/
    #   README*
    #
    def lookup_root(dir)
      root = nil
      Dir.ascend(dir || Dir.pwd) do |path|
        check = Dir[ROOT_GLOB].first
        if check
          root = path 
          break
        end
      end
      root || Dir.pwd
    end

    # Load heuristics script.
    def heuristics
      @heuristics ||= Heuristics.load(heuristics_file)
    end

    # Heurtistics script.
    def heuristics_file
      @heuristics_file ||= Dir[File.join(config_directory, 'rules.rb')].first
    end

    # Access to Repo's HISTORY file.
    def history_file
      @history_file ||= HistoryFile.new(root)
    end

    # Read history file and make a commit tag for any release not already
    # tagged. Unless the force option is set the user will be prompted for
    # each new tag.
    def autotag
      history_file.tags.each do |tag|
        if not repo.tag?(tag.name)
          chg = repo.change_by_date(tag.date)
          if chg
            if force? or ask_yn(new_tag_message(tag) + "\nCreate tag? [yN] ")
              repo.tag(chg.rev, tag, desc)
            end
          else
            puts "No commit found for #{tag.name} #{tag.date.strftime('%y-%m-%d')}."
          end
        end
      end
    end

    # Delegate to SCM adapter.
    def method_missing(s, *a, &b)
      if adapter.respond_to?(s)
        adapter.send(s, *a, &b)
      else
        super(s,*a,&b)
      end
    end

    private

    # Ask yes/no question.
    def ask_yn(message)
      case ask(message)
      when 'y', 'Y', 'yes'
        true
      else
        false
      end
    end

    #
    def new_tag_message(tag)
      "#{tag.name} / #{tag.date.strftime('%y-%m-%d')}\n#{tag.message}"
    end

  end

end