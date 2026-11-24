require_relative 'lib/vclog/version'

Gem::Specification.new do |s|
  s.name        = 'vclog'
  s.version     = VCLog::VERSION
  s.summary     = 'Cross-VCS/SCM ChangeLog Generator'
  s.description = 'VCLog is a versatile cross-VCS/SCM changelog and release history generator. ' \
                  'It supports Git, Mercurial and Subversion, and a variety of output formats.'

  s.authors  = ['Trans']
  s.email    = ['transfire@gmail.com']
  s.homepage = 'https://github.com/rubyworks/vclog'
  s.license  = 'BSD-2-Clause'

  s.metadata = {
    'homepage_uri'      => s.homepage,
    'source_code_uri'   => 'https://github.com/rubyworks/vclog',
    'bug_tracker_uri'   => 'https://github.com/rubyworks/vclog/issues',
    'changelog_uri'     => 'https://github.com/rubyworks/vclog/blob/master/History.md',
    'documentation_uri' => 'https://rubydoc.info/gems/vclog'
  }

  s.required_ruby_version = '>= 2.7'

  s.files = Dir[
    'lib/**/*', 'bin/*', 'man/**/*',
    '.yardopts', 'README.md', 'History.md', 'License.txt'
  ].select{ |f| File.file?(f) }
  s.bindir           = 'bin'
  s.executables      = Dir['bin/*'].map{ |f| File.basename(f) }
  s.require_paths    = ['lib']
  s.extra_rdoc_files = ['README.md', 'History.md', 'License.txt']

  s.add_dependency 'ansi', '>= 1.5'
  s.add_dependency 'facets', '>= 2.4'
  s.add_dependency 'json'
  s.add_dependency 'ostruct'
  s.add_dependency 'rdoc'
  s.add_dependency 'xml-simple'

  s.add_development_dependency 'rake', '>= 13'
  s.add_development_dependency 'spectrum', '>= 0.2'
  s.add_development_dependency 'assay', '>= 0.5'
end
