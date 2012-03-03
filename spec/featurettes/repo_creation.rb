module RepoCreation
  include Lime::Featurette

  Given 'a suitable Git repository' do
    url    = "git://github.com/rubyworks/vclog.git"
    name   = "vclog"
    type   = "git"
    marker = ".git"
    clone  = "git clone #{url} #{name}"

    setup_repo(name, type, marker, clone)
  end

  Given 'a suitable Mercurial repository' do
    url    = "http://bitbucket.org/birkenfeld/sphinx"
    name   = "sphinx"
    type   = "hg"
    marker = ".hg"
    clone  = "hg clone #{url} #{name}"

    setup_repo(name, type, marker, clone)
  end

  Given 'a suitable Subversion repository' do
    url    = "svn://rubyforge.org/var/svn/rubygems"
    name   = "rubygems"
    type   = "svn"
    marker = ".svn"
    clone  = "svn checkout #{url} #{name}"

    setup_repo(name, type, marker, clone)
  end

  # TODO: test darcs repo
  Given 'a suitable Darcs repository' do
    url    = 
    name   = 
    type   = "darcs"
    marker = "_darcs"
    clone  = ""
  end

  #
  # Checkout reporsitory if need be and copy to working location.
  #
  def setup_repo(name, type, marker, clone_command)
    dir = File.expand_path("tmp/hold/#{type}")
    dst = File.expand_path("tmp/repo/#{type}")

    unless File.exist?("#{dir}/#{name}/#{marker}")
      $stderr.puts("    #{clone_command}")
      `mkdir -p #{dir}` unless File.directory?(dir)
      `cd #{dir}; #{clone_command}`
    end

    unless File.directory?("#{dst}/#{name}")
      `mkdir -p #{dst}`
      `cp -r #{dir}/#{name} #{dst}/#{name}`
    end

    @working_directory = "#{dst}/#{name}"
  end

end
