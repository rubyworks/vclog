set :admin, -2, "Administrative Changes"
set :minor, -1, "Minor Enhancements"

on /^admin:/ do
  :admin
end

on /^minor:/ do
  :minor
end

on /updated? (README|PROFILE|PACKAGE|VERSION|MANIFEST)/ do
  :admin
end

