require 'dm-h2-adapter'
require 'dm-core/spec/setup'

require 'tempfile'

module DataMapper
  module Spec
    module Adapters

      class H2Adapter < Adapter

        def setup!
          adapter = DataMapper.setup(:default, {:scheme => "h2", :path => "/home/akhil/default_tests", :adapter => "h2"})
          test_connection(adapter)
          adapter
        rescue Exception => e
          puts "Could not connect to the database using '#{connection_uri}' because of: #{e.inspect}"
        end

      end
      use H2Adapter

    end
  end
end

