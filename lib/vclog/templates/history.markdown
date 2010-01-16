# <%= title %>
<% releases.each do |release| %><% tag = release.tag %>
## <%= tag.name %> / <%= tag.date.strftime('%Y-%m-%d') %>

<%= h tag.message.strip %> (<%= tag.author %>)

Changes:
<% groups(release.changes).each do |number, changes| %>
* <%= changes.size %> <%= changes[0].type_phrase %>
<% changes.sort{|a,b| b.date <=> a.date}.each do |entry| %>
    * <%= entry.message %> <% if rev %>(#<%= entry.revision %>)<% end %><% end %>
<% end %><% end %>
