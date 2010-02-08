# RELEASE HISTORY

## 1.3 / 2010-02-08

For the an end-user the only significant change is the support
of 'label:' notation for commit labels. I have found that I
am much more apt to use them if they come first in the commit
message and that some developers already use the 'label:'
notation to specify 'system module' effected --a useful system
of labeling.

Changes:

* 1 Major Enhancement

  * Support 'label:' fromat commit types

* 2 Implementation Enhancements

  * Adjust location of plugins for latest version of Plugin gem.
  * Use Erb as template system for all formats.


## 1.2 / 2009-10-26

Version 1.2 overhuals the internals so that History
output is based on scm tags, not on a pre-existing history file.
This is really the proper way to go about it and those
who use it will, I think, be happily surprised at how it
promotes good practices for the maintenance of History files.
This overhaul led to substantial changes in the command-line
interface.

Changes:

* 2 Major Enhancements

  * Rewrote History class.
  * Changed command-line interface.


## 1.1 / 2009-10-23

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

* 2 Major Enhancements

    * Improved command line interface.
    * Added output option to save changelog.


## 0.1.0 / 2009-08-17

This is the initial version of vclog.

* 1 Major Enhancement

    * Happy Birthday

