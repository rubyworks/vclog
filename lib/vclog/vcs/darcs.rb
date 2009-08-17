module VCLog

  class VCS

    # = DARCS
    #
    # Provide Darcs SCM revision tools.
    #
    # TODO: This needs to be fixed.
    #
    class DARCS

      ### Is a darcs repository?
      def repository?
        File.directory?('_darcs')
      end

      ### This is also a module function.
      module_function :repository?

      ### Cached Changelog.
      def changelog
        @changelog ||= generate_changelog
      end

      ### Generate Changelog object.
      def generate_changelog
        raise "not a darcs repository" unless repository?

        log = Changelog.new

        txt = `darcs changes` #--repo=#{@repository}`

        txt.each_line do |line|
          case line
          when /^\s*$/
          when /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun)/
          when /^\s*tagged/
            log << $'
            log << "\n"
          else
            log << line
            log << "\n"
          end
        end

        return log
      end

      ### Retrieve the "revision number" from the darcs tree.
      def calculate_version
        raise "not a darcs repository" unless repository?

        status = info.status

        changes = `darcs changes`
        count   = 0
        tag     = "0.0"

        changes.each("\n\n") do |change|
          head, title, desc = change.split("\n", 3)
          if title =~ /^  \*/
            # Normal change.
            count += 1
          elsif title =~ /tagged (.*)/
            # Tag.  We look for these.
            tag = $1
            break
          else
            warn "Unparsable change: #{change}"
          end
        end
        ver = "#{tag}.#{count.to_s}"

        return ver
        #format_version_stamp(ver, status) # ,released)
      end

    end

  end
end

