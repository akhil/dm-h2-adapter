require 'do_h2'
require 'dm-do-adapter'

module DataMapper
  module Adapters

    class H2Adapter < DataObjectsAdapter
      def initialize(name, options)
        super
      end
      def connection_uri
          "jdbc:h2://#{Dir.tmpdir}/#{storage_name}.db"
        end
    end

    const_added(:H2Adapter)

  end
end
