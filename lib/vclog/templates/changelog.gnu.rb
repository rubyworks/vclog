out = []

out << "#{title}\n" if title

changelog.by_date.each do |date, date_changes|

  date_changes.by_author.each do |author, author_changes|

    out << "#{ date }  #{ author }\n"

    author_changes.each do |entry|

      out << "        * #{entry.message.strip}"
 
      if options.extra && entry.type
        out.last << " <#{ entry.type }>"
      end

      if options.revision
        out.last << "(##{entry.revision})"
      end

    end

    out << ""

  end

end

out.join("\n") + "\n"
