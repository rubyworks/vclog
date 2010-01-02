module Syckle::Plugins

  # VClog service automatically generates changelogs from
  # SCM commit messages.
  #
  class VClog < Service

    cycle :main, :document

    available do |project|
      begin
        require 'vclog/vcs'
        true
      rescue LoadError
        false
      end
    end

    # Current version of project.
    attr_accessor :version

    # Root level changelog layout (gnu or rel). Default is gnu.
    attr_accessor :layout

    # Changelog format (html, xml or txt). Default is html.
    # This only applies to the changelog saved to the log/ directory.
    attr_accessor :format

    # If set to true will include only typed commits.
    # (types are set by adding "[type]" at end of commit messages.
    attr_accessor :typed

    # File name to store root level ChangeLog.
    # If not given, it will look for a CHANGES or CHANGELOG file.
    # If that is not found that a root level ChangeLog will not
    # be generated. But a log/changelog file will still be created.
    attr_accessor :output

    # Project unixname (for repository).
    #attr_accessor :unixname

    # Developers URL to repository. Defaults to Rubyforge address.
    #attr_accessor :repository

    # Username. Defaults to ENV['RUBYFORGE_USERNAME'].
    #attr_accessor :username

    #
    def initialize_defaults
      @version    = metadata.version
      @format     = 'html'
      @layout     = 'gnu'
      @typed      = false

      #@unixname   = metadata.project

      #@protocol   = DEFAULT_PROTOCOL
      #@tagpath    = DEFAULT_TAGPATH
      #@branchpath = DEFAULT_BRANCHPATH

      # fallback default is for rubyforge.org
      #@username   = ENV['RUBYFORGE_USERNAME']
      #@repository = metadata.repository || "rubyforge.org/var/svn/#{unixname}"
      #if i = @repository.index('//')
      #  @repository = @repository[i+2..-1]
      #end
    end

    #
    def valid?
      return false unless format =~ /^(html|xml|txt)$/
      return false unless layout =~ /^(gnu|rel)$/
      return true
    end

    # Developer domain is "username@repository".
    #def developer_domain
    #  "#{username}@#{repository}"
    #end

    #
    def format=(f)
      @format = f.to_s.downcase
    end

    #
    def layout=(f)
      @layout = f.to_s.downcase
    end

    # Generate changelogs.
    def document
      document_master_changelog
      document_public_changelog
    end

    # TODO: apply_naming_policy ?
    def document_master_changelog
      format = self.format || 'txt'
      #apply_naming_policy('changelog', log_format.downcase)
      file = (project.log + "changelog.#{format}").to_s
      if dryrun?
        report "vclog > #{file}"
      else
        changed = changelog.save(file, format)
        if changed
          report "Updated #{relative_from_root(file)}"
        else
          report "#{relative_from_root(file)} is current"
        end
      end
    end

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

    # Access to version control.
    def vcs
      @vcs ||= VCLog::VCS.new #(self)
    end

    # Get changelog from ProUtils VCS.
    def changelog
      @changelog ||= vcs.changelog
    end

    #
    def relative_from_root(path)
      Pathname.new(path).relative_path_from(project.root)
    end

  end

end

