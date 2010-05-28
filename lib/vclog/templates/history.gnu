# <%= title %>
<% history.releases.sort.each do |release| %><% tag = release.tag %>
## <%= tag.name %> / <%= tag.date.strftime('%Y-%m-%d') %>

<%= h tag.message.strip %> (<%= tag.author %>)

<% if options.extra %>Changes:
<% release.groups.each do |number, changes| %>
* <%= changes.size %> <%= changes[0].type_phrase %>
<% changes.sort{|a,b| b.date <=> a.date}.each do |entry| %>
    * <%= entry.message %> <% if options.revision %>(#<%= entry.revision %>)<% end %><% end %>
<% end %><% end %><% end %>
