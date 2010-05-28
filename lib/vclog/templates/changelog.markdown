# <%= title %>
<% changelog.by_date.each do |date, date_changes| %><% date_changes.by_author.each do |author, author_changes| %>
## <%= date %> <%= author %>
    <% author_changes.each do |entry| %>
* <%= entry.message %> <% if entry.type %><<%= entry.type %>><% end %><% if options.revision %>(#<%= entry.revision %>)<% end %><% end %>
<% end %><% end %>
