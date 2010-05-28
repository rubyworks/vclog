Given /a suitable Subversion repository/ do
  url    = "svn://rubyforge.org/var/svn/rubygems"
  name   = "rubygems"
  type   = "svn"
  marker = ".svn"
  clone  = "svn checkout #{url} #{name}"

  setup_repo(name, type, marker, clone)

  #dir = File.expand_path("tmp/hold/#{type}")
  #unless File.exist?("#{dir}/#{name}/.svn")
  #  `mkdir -p #{dir}; cd #{dir}; svn checkout #{url} #{name}`
  #end
  #create_dir(type)
  #cd(type)
  #run "cp -r #{dir} #{name}"
  #cd(name)
end

Given /a suitable Git repository/ do
  url    = "git://github.com/proutils/vclog.git"
  name   = "vclog"
  type   = "git"
  marker = ".git"
  clone  = "git clone #{url} #{name}"

  setup_repo(name, type, marker, clone)

  #create_dir('git')
  #cd('git')
  #unless File.exist?("#{name}/.git")
  #  cmd = "git clone #{url} #{name}"
  #  run cmd
  #end
  #cd(name)
end

Given /a suitable Mercurial repository/ do
  url    = "http://bitbucket.org/birkenfeld/sphinx"
  name   = "sphinx"
  type   = "hg"
  marker = ".hg"
  clone  = "hg clone #{url} #{name}"

  setup_repo(name, type, marker, clone)

  #create_dir('hg')
  #cd('hg')
  #unless File.exist?("#{name}/.hg")
  #  cmd = "hg clone #{url} #{name}"
  #  run cmd
  #end
  #cd(name)
end

Given /a suitable Darcs repository/ do
  url  = 
  name = 
  type   = "darcs"
  marker = "_darcs"
  clone  = ""

  #create_dir('darcs')
  #cd('darcs')
  #unless File.exist?("#{name}/_darcs")
  #  cmd = "darcs clone "
  #  #run cmd
  #end
  #cd(name)
end

