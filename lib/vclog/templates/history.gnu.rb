
out = []

out << "#{title}"

history.releases.sort.each do |release|

  tag = release.tag

  out << "\n#{tag.name} / #{tag.date.strftime('%Y-%m-%d')}"

  out << "\n#{tag.message.strip} (#{tag.author})"

  if !(options.summary or release.changes.empty?)

    out << "\nChanges:"

    release.groups.each do |number, changes|

      out << "\n* #{changes.size} #{changes[0].label }\n"

      changes.sort{|a,b| b.date <=> a.date}.each do |entry|
        msg = entry.to_s(:summary=>!options.detail) 

        msg << "\n(##{entry.id})" if options.reference

        out << msg.tabto(6).sub('      ','    * ')
      end

    end

  end 

  out << ""

end

out.join("\n") + "\n"

