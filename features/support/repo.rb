#
def setup_repo(name, type, marker, clone_command)
  dir = File.expand_path("tmp/hold/#{type}")

  unless File.exist?("#{dir}/#{name}/#{marker}")
    $stderr.puts("    #{clone_command}")
    `mkdir -p #{dir}` unless File.directory?(dir)
    `cd #{dir}; #{clone_command}`
  end

  run "cp -r #{dir} #{type}"
  cd(type)
  cd(name)
end

