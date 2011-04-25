require 'do_h2'
require 'dm-do-adapter'

module DataMapper
  module Adapters

    class H2Adapter < DataObjectsAdapter
    end

    const_added(:H2Adapter)

  end
end
