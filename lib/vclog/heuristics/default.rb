set :major,  1, "Major Enhancements"
set :minor, -1, "Minor Enhancements"
set :admin, -2, "Administrative Changes"

on /updated? (README|PROFILE|PACKAGE|VERSION|MANIFEST)/ do
  :admin
end

on /bump(ed)? version/ do
  :admin
end

on /^(\w+):/ do |word|
  word.to_sym
end

on /\[(\w+)\]\s*$/ do |word|
  word.to_sym
end

