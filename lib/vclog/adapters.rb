require 'vclog/adapters/svn'
require 'vclog/adapters/git'
require 'vclog/adapters/hg'
#require 'vclog/vcs/darcs'

module VCLog

  module Adapters

    #
    def self.factory(config) #, options={})
      type = read_type(config.root)
      raise ArgumentError, "Not a recognized version control system." unless type
      const_get(type.capitalize).new(config) #, options)
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
