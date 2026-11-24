module Shellout
  include Spectrum::Featurette

  When 'I run `(.*?)`' do |cmd|
    @stdout, @stderr, @status = run_command(cmd, @working_directory)
  end

  Then 'the exit status should be (\d+)' do |status|
    @status.assert == status.to_i
  end

  Then 'the output should include "(.*?)"' do |text|
    @stdout.assert.include?(text)
  end

  Then 'the output should not include "(.*?)"' do |text|
    @stdout.refute.include?(text)
  end

  Then 'the output should be "(.*?)"' do |text|
    @stdout.strip.assert == text
  end

end
