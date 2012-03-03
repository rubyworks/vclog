require 'open3'

module Shellout
  include Lime::Featurette

  When 'I run `(((.*?)))`' do |cmd|
    Dir.chdir(@working_directory) do
      @stdout, @stderr, @status = Open3.capture3(cmd)
    end
  end

  Then 'the exit status should be (((\d+)))' do |status|
    @status = status.to_i
  end

end
