set :major,  1, "Major Enhancements"
set :minor, -1, "Minor Enhancements"
set :admin, -2, "Administrative Changes"

on /^admin:/ do
  :admin
end

on /^minor:/ do
  :minor
end

on /^major:/ do
  :major
end

on /updated? (README|PROFILE|PACKAGE|VERSION|MANIFEST)/ do
  :admin
end

on /bump(ed)? version/ do
  :admin
end

