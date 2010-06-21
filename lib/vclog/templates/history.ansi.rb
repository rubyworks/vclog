require 'ansi'

out = []

out << "#{title.ansi(:bold)}"

history.releases.sort.each do |release|

  tag = release.tag

  out << "\n#{tag.name} / #{tag.date.strftime('%Y-%m-%d')}".ansi(:bold)

  out << "\n#{tag.message.strip} (#{tag.author})"

  if options.extra && !release.changes.empty?

    #out << "\nChanges:".ansi(:green)

    release.groups.each do |number, changes|

      out << "\n* " + "#{changes.size} #{changes[0].label}\n"

      changes.sort{|a,b| b.date <=> a.date}.each do |entry|

        line = "#{entry.message.strip}"

        if options.revision
          out.last <<  "(##{entry.revision})"
        end

        case entry.level
        when 1
          line = line.ansi(:yellow)
        when 0
          line = line.ansi(:green)
        when -1
          line = line.ansi(:cyan)
        else
          if entry.level > 1
            line = line.ansi(:red) 
          else
            line = line.ansi(:blue)
          end
        end

        out << "    * " + line

      end

    end

  end 

  out << ""

end

out.join("\n") + "\n"

