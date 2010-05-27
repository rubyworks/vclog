require 'vclog/adapters/svn'
require 'vclog/adapters/git'
require 'vclog/adapters/hg'
#require 'vclog/vcs/darcs'

module VCLog

  module Adapters

    #
    def self.factory(root=nil)
      root = root || Dir.pwd
      type = read_type(root)
      raise ArgumentError, "Not a recognized version control system." unless type
      const_get(type.capitalize).new(root)
    end

    #
    def self.read_type(root)
      dir = nil
      Dir.chdir(root) do
        dir = Dir.glob("{.svn,.git,.hg,_darcs}").first
      end
      dir[1..-1] if dir
    end

  end

end
