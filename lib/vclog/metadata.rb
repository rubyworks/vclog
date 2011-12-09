module VCLog

  def self.metadata
    @metadata ||= (
      require 'yaml'
      YAML.load(File.dirname(__FILE__) + '/../vclog.yml')
    )
  end

  def self.const_missing(name)
    metadata[name.to_s.downcase] || super(name)
  end

end

