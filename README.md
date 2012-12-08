# VCLog

[Website](http://rubyworks.github.com/vclog) /
[Source Code](http://github.com/rubyworks/vclog) /
[Report Issue](http://github.com/rubyworks/vclog/issues) /
[Mailing List](http://googlegroups.com/group/rubyworks-mailinglist)

[![Build Status](https://secure.travis-ci.org/rubyworks/vclog.png)](http://travis-ci.org/rubyworks/vclog)

## VCLog is a versitile and customizable cross-VCS/SCM changelog and release history generator.

## Supported Systems

VCLog is a multi-platform VCS logging tool.
It curently supports the following Version Control Systems:

* <a href="http://git-scm.com/">Git</a>
* <a href="http://mercurial.selenic.com/">Mercurial</a>
* <a href="http://subversion.apache.org/">Subversion</a>

Sunversion support is limited however. See Limitations noted below.


## Instructions

### Creating Changelogs

The default output is an ANSI colored GNU-like changelog.
From a repository's root directory try:

    $ vclog

The is the same as specifying 'changelog' or 'log'.

    $ vclog log

To generate an a different format use -f:

    $ vclog -f xml

### Creating Release Histories

To get a release history specify `-r`, `--release` or `--history` option.

    $ vclog -r

Again the default format is an ANSI colored GNU-like text style.

Unlike change logs, release histories group changes by tags. The tag
message is used as the release note. If the underlying SCM doesn't
support tag messages than the message of the first commit prior to
the tag is used.

See 'vclog help' for more options.

### Bumping Versions

VCLog can also be used to intelligently bump versions. To see the current
tag version:

    $ vclog-version
    1.1.0

To see the next reasonable version based on current changes:

    $ vclog-bump
    1.2.0

VCLog can determine the appropriate version based on commit level. Any
commit with a level greater than 1 will bump the major number, while any
commit with a level of 0 or 1 will bump the minor number. All lower
level only bump the patch level.

### Writing Heuristics

You can configure custom log heuristics for your project. VCLog uses
the {confection gem}[http://rubyworks.github.com/confection] to
handle configuration, and will look for a `.confile` or `Confile` in
which to find a `vclog` section.

    vclog do
      ...
    end

Within this block we can define rules via the #on method.

    on /updated? (README|VERSION|MANIFEST)/ do |commit|
      commit.label = "Adminstrative Changes"
      commit.level = -3
    end

To make things easier we can setup commit types. Types make it easier
to categorize commits, assigning them labels and levels base on the 
type name. Use #type in the rules to specify the level and label of 
a commit type.

    type :admin,  -2, "Administrave Changes"

    on /updated? (README|VERSION|MANIFEST)/ do |commit|
      commit.type = :admin
    end

These rules can also "massage" the commit message.

    on /\Aadmin:/ do |commit, matchdata|
      commit.type    = :admin
      commit.message = matchdate.post_match
    end

Lastly, we can customize the colorization of the certain formats via #colors
method.

    colors :blue, :cyan, :green, :yellow, :red


## Limitations

### Subversion

Because Subversion is a centralized version control system, it contacts
the server every time 'svn log' is run. For this reason, having vclog
generate a release history is likely to fail since it must run 'svn log'
for each tag. Any repository with more than a few tags may be denied
access by the server for making too many rapid requests. I have no
idea how to remedy this issue. If you have any ideas please let me know.


## Copyrights

VCLog (http://rubyworks.github.com/vclog)

Copyright &copy; 2008 Rubyworks. All rights reserved.

VCLog is distributable in accordance with the terms of the *FreeBSD* license.

See License.txt for details.

