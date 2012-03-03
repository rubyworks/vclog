#
def setup_repo(name, type, marker, clone_command)
  dir = File.expand_path("tmp/hold/#{type}")
  dst = File.expand_path("tmp/aruba")

  unless File.exist?("#{dir}/#{name}/#{marker}")
    $stderr.puts("    #{clone_command}")
    `mkdir -p #{dir}` unless File.directory?(dir)
    `cd #{dir}; #{clone_command}`
  end

  #unless File.exist?("tmp/aruba/#{type}/#{name}")
    `mkdir -p #{dst}`
    `cp -r #{dir} #{dst}/#{type}/`
  #end

  cd("#{type}/#{name}")
end

