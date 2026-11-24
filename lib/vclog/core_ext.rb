require 'ostruct'
require 'facets/string/fold'
require 'facets/kernel/ask'

class OpenStruct
  method_undef(:type) if method_defined?(:type)
end

class String
  # Indent the text so its first line with any content starts at column
  # +n+, keeping the relative indentation of the lines after it. Facets
  # had this until 4.0.
  def tabto(n)
    lead = self[/^([ \t]*)\S/, 1].to_s.size
    if n >= lead
      gsub(/^(?=.)/, ' ' * (n - lead))
    else
      gsub(/^[ \t]{0,#{lead - n}}/, '')
    end
  end unless method_defined?(:tabto)
end
