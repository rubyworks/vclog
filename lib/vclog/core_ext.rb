require 'facets/string/fold'
require 'facets/string/indent'
require 'facets/string/tabto'
require 'facets/string/margin'
require 'facets/enumerable/group_by'
require 'facets/kernel/ask'

class OpenStruct
  method_undef(:type) if method_defined?(:type)
end

