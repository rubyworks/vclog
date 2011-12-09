module VCLog

  def self.metadata
    @metadata ||= (
      require 'yaml'
      YAML.load_file(File.dirname(__FILE__) + '/../vclog.yml')
    )
  end

  def self.const_missing(name)
    key = name.to_s.downcase
    metadata.key?(key) ? metadata[key] : super(name)
  end

end

