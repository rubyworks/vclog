require 'ansi'

out = []

out << "#{title}\n".ansi(:bold) if title

changelog.by_date.each do |date, date_changes|

  date_changes.by_author.each do |author, author_changes|

    out << "#{ date }  #{ author }\n".ansi(:bold)

    author_changes.sort!{|a,b| b.level <=> a.level}

    author_changes.each do |entry|

      line = "#{entry.message.strip}"

      if options.extra && entry.type
        line << " <#{ entry.type }>"
      end

      if options.revision
        line << " (##{entry.revision})"
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

      out << "  * " + line

    end

    out << ""

  end

end

out.join("\n") + "\n"
