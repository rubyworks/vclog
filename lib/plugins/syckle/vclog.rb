module Syckle::Plugins

  # VClog service generates changelogs from
  # SCM commit messages.
  #
  # TODO: Support multiple formats in one pass.
  class VClog < Service

    cycle :main, :document

    #available do |project|
    #  begin
    #    require 'vclog/vcs'
    #    true
    #  rescue LoadError
    #    false
    #  end
    #end

    # Current version of project.
    attr_accessor :version

    # Changelog format. Default is +html+.
    # Supports +html+, +xml+, +json+, +yaml+, +rdoc+, +markdown+, and +gnu+.
    attr_accessor :formats

    # Changelog layout type (+log+ or +rel+). Default is +log+.
    attr_accessor :type

    # Output file to store changelog.
    # The defualt is 'log/vclog/changelog.{format}'.
    attr_accessor :output

    # Show revision numbers (true/false)?
    attr_accessor :rev

    # Some formats, such as +rdoc+, use a title field. Defaults to project title.
    attr_accessor :title

    # Some formats can reference an optional stylesheet (namely +xml+ and +html+).
    attr_accessor :style

    #
    def initialize_defaults
      require 'vclog'
      @version    = metadata.version
      @title      = metadata.title
      @formats    = ['atom']
      @type       = 'log'
    end

    #
    def valid?
      return false unless format =~ /^(html|yaml|json|xml|rdoc|markdown|gnu|txt|atom)$/
      return false unless type   =~ /^(log|rel|history|changelog)$/
      return true
    end

    #
    def formats=(f)
      @formats = f.to_list
    end

    alias_method :format=, :formats=

    #
    def type=(f)
      @type = f.to_s.downcase
    end

    # Generate changelog.
    def document
      document_changelog
    end

    #++
    # TODO: apply_naming_policy ?
    #--

    def document_changelog
      formats.each do |format|
        case type
        when 'rel', 'history'
          file = output || (project.log + "vclog/history.#{format}").to_s
        else
          file = output || (project.log + "vclog/changelog.#{format}").to_s
        end
        #apply_naming_policy('changelog', log_format.downcase)
        if dryrun?
          report "# vclog --#{type} -f #{format} -o #{file}"
        else
          changed = save(format, file)
          if changed
            report "Updated #{relative_from_root(file)}"
          else
            report "Current #{relative_from_root(file)}"
          end
        end
      end
    end

    # Save changelog/history to +output+ file.
    def save(format, output)
      text = render(format)
      if File.exist?(output)
        if File.read(output) != text
          File.open(output, 'w'){ |f| f << text }
          true
        else
          false
        end
      else
        dir = File.dirname(output)
        mkdir_p(dir) unless File.exist?(dir)
        File.open(output, 'w'){ |f| f << text }
      end
    end

    ## Returns changelog or history depending on type selection.
    #def log
    #  @log ||= (
    #    case type
    #    when 'log', 'changelog'
    #      log = vcs.changelog
    #    when 'rel', 'history'
    #      log = vcs.history(:title=>title, :version=>version)
    #    else
    #      log = vcs.changelog
    #    end
    #  )
    #end

    # Access to version control system.
    def vcs
      #@vcs ||= VCLog::VCS.new #(self)
      @vcs ||= VCLog::Adapters.factory #(root)
    end

    # Convert log to desired format.
    def render(format)
      doctype = type
      doctype = 'history'   if doctype == 'rel'
      doctype = 'changelog' if doctype == 'log'

      options = {
        :stylesheet => style,
        :revision   => rev,
        :version    => version,
        :title      => title
      }
      vcs.display(doctype, format, options)
    end


=begin
    #
    def document_public_changelog
      if output
        file = project.root + output
      else
        file = project.root.glob_first("{CHANGES,CHANGELOG}{.txt,}", :casefold)
      end

      if file
        #file = (project.root + file).to_s
        if dryrun?
          report "vclog > #{file}"
        else
          public_changelog = typed ? changelog.typed : changelog
          if layout == 'rel'
            changed = public_changelog.save(file.to_s, :rel, metadata.version, metadata.release)
          else
            changed = public_changelog.save(file.to_s, :gnu)
          end
          if changed
            report "Updated #{relative_from_root(file)}"
          else
            report "#{relative_from_root(file)} is current"
          end
        end
      end
    end
=end

    #
    def relative_from_root(path)
      Pathname.new(path).relative_path_from(project.root)
    end

  end

end

