out = []

out << "# #{title}"

changelog.by_date.each do |date, date_changes|

  date_changes.by_author.each do |author, author_changes|

    out << "\n## #{date} #{author}\n"

    author_changes.each do |entry|

      #out << "* #{entry.message.strip}"

      msg = entry.message.strip
      out << msg.tabto(2).sub('  ','* ')

      if entry.type
        out.last << " [#{entry.type}]"
      end

      if options.reference
        out.last << " (##{entry.id})"
      end

    end

  end

end

out.join("\n") + "\n\n"

