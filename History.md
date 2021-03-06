# RELEASE HISTORY

## 1.9.3 / 2012-04-09

This release should finally fix issue #14. If also adds support
for RC based configuration.

Changes:

* Fix issue #14.
* Add support for RC.


## 1.9.2 / 2012-03-03

Adds `vclog-news` command to output the lastest release entry in a project History file.
Also attempts to fix issue #14 in which template is not being found --will at least
report more useful error message if it happens in the future. Also, improved handling
of configuration. You can now use `.vclog`, `config/vclog` or `.config/vclog`
by defatult, or add `vclog: path/to/config/file` entry to `.map` file is you wish
to use unconventional location.

Changes:

* Add news command to get latest release history.
* Improve configuration file handling.
* Improve Report code to avoid missing templates.
* Switch to Lime for spec testing, instead of Cucumber.


## 1.9.1 / 2011-12-13

Fixes a couple of issues found with the last release.

Changes:

* Fix revision id in rss and atom formats.
* Fix tag id in git tag parser.


## 1.9.0 / 2011-12-12

This is a BIG release and much has changed, so be sure to read the following
carefully if you've used VClog before.

First of all, the command line interface no longer uses the subcommand pattern.
Instead independent commands have been created for each use, e.g. `vclog-version`
instead of `vclog version`. In addition the plain `vclog` command now handles
both changelog and release history reports. To get a release history insead of
a changelog, use the `-r` option.

Next up, this release also adds in full commit message support via the `-d`/`--detail`
option, where as previously some formats were limited to one-line message summaries.
Also, the `-p`/`--point` option has been added which will split a commit message
into separate points (points are recognized by astrisks flush to the left margin).

Custom hueristics configuration blocks no longer receive the commit message,
but the commit object instead, which can be manipulated directly, rather then
return a limited set of possible changes. This allows for rules to be much more
flexible.

Since the last release wasn't widely publisized, I also want to mention again that
configuration is now handled by the `confection` gem, meaning custom heuristics
must be place in a projects `.confile` or `Confile`. See the latest README for more
details.

Changes:

* Separate commands and new cli interface.
* Support for full commit messages.
* Point option splits commit messages into point messages.
* Heuristic rules receive commit object instead of message.


== 1.8.2 / 2011-12-08

This release changes the way in which vclog is configured to use the Confection
gem. This means VCLog custom configuration for a project must go in a `vclog do`
block in the `Confile` or `.confile` project file. In addtion this release
brings the build config up to date and switches the project over to the
BSD-2-Clause license.

Changes:

* Use Confection gem for cusomt configs.
* Modernize build config for latest tools.
* Switch to BSD-2-Clause license.


== 1.8.1 / 2010-11-22

This release corrects the tag dates on Histories. Where possible the tag date is used rather than the commit date (of the most recent commit made relative to the tag). Primarily this effects git repositories --a separate tag date is not supported by all SCMs. This release also fixes a bug in the hg adapter that prevented auto-tagging.

Changes:

* Use tag date instead of commit date in history.
* Fix typo in hg adapter's autotag method.
* Add history file option to autotag command.


== 1.8.0 / 2010-11-21

Under the hood, VCLog now has a Repo class that acts as a central controller. This has improved the code base substantially and should could to do so as this new design is further embraced. This release also introdces a new `autotag` feature, which makes it possible to "reverse engineer" a Release History file. It will parse the entries from a HISTORY.* file and ensure that corresponding tags exists in the version control system.

Changes:

* Add Repo class which acts as central control.
* Add autotag feature to ensure release history tags exits.


## 1.7.0 / 2010-06-27

In this release the heuristics interface has changed such that the block is passed the commit message and the matchdata, instead of  the previous matchdata splat. The rule can alos return either the sybolic label or a two element array of label and new message, which allows the rule to "massage" the message as needed. This release also improves the git log parser to be much more robust. 

Changes:

* Pass message and matchadata to heuristics rule interface.
* Improve git log parser, which should handle all possible cases now.


## 1.6.1 / 2010-06-23

This release repairs the Atom feed format and adds an RSS feed format. Both formats are nearly conformant with strict validations --only a couple minor issues remain to iron out (such as embedded feed url). Ragardless, they should work fine with feed readers (which are not as strict).

Changes:

* Repair and improve Atom feed format.
* Add RSS feed format.
* Fix Git email address value.
* Add title to HTML Change Log format.


## 1.6.0 / 2010-06-22

Previous versions utilized a system of "commit tagging" to identify types of commits. This proved less than optimal --it was unconventional, but worse it was easy to forget to put the proper label in the message. The new version of VClog uses a customizable heuristics systems instead. Rather than be limited to a strict syntax structure, you can write matching rules in .config/vclog/rules.rb that determine the commit type, and set descriptive labels for each type. This makes it very easy to get excellent History output. Also in this release the command-line interface has changed to use subcommands. And the default output format is now an ANSI-color GNU-like format. Use `-f gnu` to get the old default format.

Changes:

* 2 Major Enhancements

  * Heuristics system for categorizing commits
  * Command-line interface uses subcommands


## 1.5.0 / 2010-05-29

This release adds support for Mercurial repositories and Atom newsfeed output format. The commandline inteface has change such that <code>--foramt</code>/<code>-f</code> is used to select the format instead of using the previous per-format options, e.g. use <code>-f xml</code> instead of <code>--xml</code>. This release also includes some subtantial changes under-the-hood --the first of a two part code refactoring process.

Changes:

* 2 Major Enhancements

  * Add Mercurial support
  * Add Atom feed format

* 1 Minor Enhancement

  * Select format using -f option.


## 1.4.0 / 2010-05-26

This release includes some basic improvments and a few bug fixes. The primary change you might encounter is the need to use -e or --extra in order to see the detailed Changes list in the Release History. Also changed 'git-log' to 'git log', as it seems the latest versions of git does not support the many executables any longer. SVN support requires xmlsimple library. Note also that SVN support is lack luster at this time becuase it hits the server every time an 'svn log' command is issued which is done once for each tag when a history is generated (any one know a better way?).

Changes:

* 1 Minor Enhancement

  * Use -e or --extra to see Changes list in release history.
  * Use xmlsimple for parsing SVN log output.
  * Improve git log parsing with --pretty option.

* 2 Bug Fixes

  * Sort release tags in correct order.
  * Change 'git-log' to 'git log'.


## 1.3.0 / 2010-02-08

For the an end-user the only significant change is the support of 'label:' notation for commit labels. I have found that I am much more apt to use them if they come first in the commit message and that some developers already use the 'label:' notation to specify 'system module' effected --a useful system of labeling.

Changes:

* 1 Major Enhancement

  * Support 'label:' fromat commit types

* 2 Implementation Enhancements

  * Adjust location of plugins for latest version of Plugin gem.
  * Use Erb as template system for all formats.

* 1 Bug Fix

  * Corrected error for --current and --bump commands.


## 1.2.0 / 2009-10-26

Version 1.2 overhuals the internals so that History output is based on scm tags, not on a pre-existing history file. This is really the proper way to go about it and those who use it will, I think, be happily surprised at how it promotes good practices for the maintenance of History files. This overhaul led to substantial changes in the command-line interface.

Changes:

* 2 Major Enhancements

  * Rewrote History class.
  * Changed command-line interface.


## 1.1.0 / 2009-10-23

This release adds yaml and json formats an improves
the command.

Changes:

* 2 Major Enhancements

    * Added YAML format.
    * Added JSON format.

* 1 Minor Enhancements

    * Use OptionParser instead of GetoptLong.


## 1.0.0 / 2009-10-13

This is the first "production" release of VCLog.

Changes:

* 2 Major Enhancements

    * Improved command line interface.
    * Added output option to save changelog.


## 0.1.0 / 2009-08-17

This is the initial version of vclog.

Changes:

* 1 Major Enhancement

    * Happy Birthday

