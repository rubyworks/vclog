require 'ansi'

out = []

out << "#{title.ansi(:bold)}"

history.releases.sort.each do |release|
  tag = release.tag

  # TODO: support verbose option
  #if verbose?
  #  out << "\n#{tag.name} / #{tag.date.strftime('%Y-%m-%d %H:%M')}".ansi(:bold)
  #else
    out << "\n#{tag.name} / #{tag.date.strftime('%Y-%m-%d')}".ansi(:bold)
  #end

  out << "\n#{tag.message.strip} (#{tag.author})"

  if !(options.summary or release.changes.empty?)

    #out << "\nChanges:".ansi(:green)

    release.groups.each do |number, changes|

      out << "\n* " + "#{changes.size} #{changes[0].label}\n"

      changes.sort{|a,b| b.date <=> a.date}.each do |entry|
        msg = entry.to_s(:summary=>!options.detail)

        case entry.level
        when 1
          msg = msg.ansi(:yellow)
        when 0
          msg = msg.ansi(:green)
        when -1
          msg = msg.ansi(:cyan)
        else
          if entry.level > 1
            msg = msg.ansi(:red) 
          else
            msg = msg.ansi(:blue)
          end
        end

        msg << "\n(##{entry.id})" if options.reference

        out << msg.tabto(6).sub('      ','    * ')
      end

    end

  end 

  out << ""
end

out.join("\n") + "\n"
