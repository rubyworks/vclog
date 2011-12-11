require 'ansi'

out = []

out << "#{title}\n".ansi(:bold) if title

changelog.by_date.each do |date, date_changes|

  date_changes.by_author.each do |author, author_changes|

    out << "#{ date }  #{ author }\n".ansi(:bold)

    author_changes.sort!{|a,b| b.level <=> a.level}

    author_changes.each do |entry|
      msg = entry.to_s(:summary=>!options.detail)

      #if !options.summary && entry.type
      #  msg << " [#{ entry.type }]"
      #end

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

      out << msg.tabto(4).sub('    ','  * ')
    end

    out << ""

  end

end

out.join("\n") + "\n"
