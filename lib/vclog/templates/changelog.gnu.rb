out = []

out << "#{title}\n" if title

changelog.by_date.each do |date, date_changes|

  date_changes.by_author.each do |author, author_changes|
    out << "#{ date }  #{ author }\n"

    author_changes.each do |entry|
      msg = entry.to_s(:summary=>!options.detail)

      #msg << " [#{entry.type}]" if entry.type && !options.summary
      msg << "\n(##{entry.id})" if options.reference

      out << msg.tabto(8).sub('        ','      * ')
    end

    out << ""
  end

end

out.join("\n") + "\n"
