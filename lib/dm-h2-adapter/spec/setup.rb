require 'dm-h2-adapter'
require 'dm-core/spec/setup'

require 'tempfile'

module DataMapper
  module Spec
    module Adapters

      class H2Adapter < Adapter
        def connection_uri
          if name == :default
            "h2://#{Dir.tmpdir}/#{storage_name}.db"
          else
            # sqlite doesn't support two in memory dbs
            "h2://#{Dir.tmpdir}/#{storage_name}.db"
          end
        end
      end

      use H2Adapter

    end
  end
end

