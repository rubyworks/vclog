# TODO

## For 2.0

* Remove the deprecated executables `vclog-version`, `vclog-bump`,
  `vclog-news`, `vclog-formats` and `vclog-autotag` (the files in
  `bin/`, the "Deprecated Commands" feature in
  `spec/feature_commands.rb`, and the mentions in the README and
  `man/man1/vclog.1.ronn`). They were deprecated in 1.11.0, when their
  work moved to subcommands: `vclog version`, `vclog bump`, and so on.
