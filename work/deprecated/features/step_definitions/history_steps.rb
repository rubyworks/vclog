Given /^a SVN repository/ do
  @directory = File.dirname(__FILE__) + '/../../test/fixtures/tzinfo'
  @tag_numbers = Dir["@directory/tags/*"].map{ |d| File.basename(d) }
end

# For git we will have to use the VCLog project itself, I guess.
Given /^a Git repository/ do
  @directory = File.dirname(__FILE__) + '/../..' #/fixtures/git-repo'
  tags1 = `cd #{@directory}; git tag -l "[0-9]*"`
  tags2 = `cd #{@directory}; git tag -l "v[0-9]*"`
  @tag_numbers = tags1.split("\n") + tags2.split("\n")
end

When /I generate a History/ do
  @system  = VCLog::VCS.factory(@directory)
  @history = VCLog::History.new(@system)
end

Then /it should include all tags/ do
  tags = @history.tags.map{ |t| t.name }
  tags.sort.assert == @tag_numbers.sort
end

And /^the list of releases should be in order from newest to oldest/ do
  rels_names = @history.releases.map{ |r| r.tag.name }
  rels_names.shift # remove imaginary current tag
  rels_names.assert == @tag_numbers.sort.reverse
end

