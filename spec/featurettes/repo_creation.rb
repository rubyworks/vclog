module RepoCreation
  include Spectrum::Featurette

  Given 'a suitable Git repository' do
    @working_directory = git_fixture
  end

end
