out = []

out << "# #{title || 'RELEASE HISTORY'}"

history.releases.sort.each do |release|

  tag = release.tag

  out << "\n## #{tag.name} / #{tag.date.strftime('%Y-%m-%d')}"

  out << "\n#{tag.message.strip} (#{tag.author})"

  if options.extra && !release.changes.empty?

    out << "\nChanges:"

    release.groups.each do |number, changes|

      out << "\n* #{changes.size} #{changes[0].label }\n"

      changes.sort{|a,b| b.date <=> a.date}.each do |entry|

        out << "    * #{entry.message.strip}"

        if options.revision
          out.last <<  "(##{entry.revision})"
        end

      end

    end

  end 

  out << ""

end

out.join("\n") + "\n"

