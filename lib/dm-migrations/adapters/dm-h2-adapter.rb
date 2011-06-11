require 'dm-migrations/auto_migration'
require 'dm-migrations/adapters/dm-do-adapter'

module DataMapper
  module Migrations
    module H2Adapter

      include DataObjectsAdapter

      # @api private
      def self.included(base)
        base.extend DataObjectsAdapter::ClassMethods
        base.extend ClassMethods
      end

      # @api semipublic
      def storage_exists?(storage_name)
        a = select("SHOW columns from #{storage_name}")
        a.size > 0
      end

      # @api semipublic
      def field_exists?(storage_name, field)
        result = select("SHOW COLUMNS FROM #{quote_name(storage_name)} LIKE ?", field).first
        result ? result.field == field : false
      end

      module SQL #:nodoc:
#        private  ## This cannot be private for current migrations

        VALUE_METHOD = RUBY_PLATFORM[/java/] ? :variable_value : :value

        # @api private
        def supports_serial?
          true
        end

        # @api private
        def supports_drop_table_if_exists?
          true
        end

        # @api private
        def schema_name
          # TODO: is there a cleaner way to find out the current DB we are connected to?
          normalized_uri.path.split('/').last
        end

        # @api private
        def create_table_statement(connection, model, properties)
          statement = DataMapper::Ext::String.compress_lines(<<-SQL)
            CREATE TABLE #{quote_name(model.storage_name(name))}
            (#{properties.map { |property| property_schema_statement(connection, property_schema_hash(property)) }.join(', ')},
            PRIMARY KEY(#{ properties.key.map { |property| quote_name(property.field) }.join(', ')}))
          SQL

          statement
        end

         # @api semipublic
        def create_model_storage(model)
          name       = self.name
          properties = model.properties_with_subclasses(name)

          return false if storage_exists?(model.storage_name(name))
          return false if properties.empty?

          with_connection do |connection|
            statements = [ create_table_statement(connection, model, properties) ]
            statements.concat(create_index_statements(model))
            statements.concat(create_unique_index_statements(model))

            statements.each do |statement|
              command   = connection.create_command(statement)
              puts  "#{command.inspect}---11111111111"
              command.execute_non_query
            end
          end

          true
        end

        # @api private
        def property_schema_hash(property)
          schema = super

          if property.kind_of?(Property::Text)
            schema[:primitive] = text_column_statement(property.length)
            schema.delete(:default)
          end

          if property.kind_of?(Property::Integer)
            min = property.min
            max = property.max

            schema[:primitive] = integer_column_statement(min..max) if min && max
          end

          schema
        end

        # @api private
        def property_schema_statement(connection, schema)
          statement = super

          if supports_serial? && schema[:serial]
            statement << ' AUTO_INCREMENT'
          end

          statement
        end

        # @api private
        def character_set
          @character_set ||= show_variable('character_set_connection') || DEFAULT_CHARACTER_SET
        end

        # @api private
        def collation
          @collation ||= show_variable('collation_connection') || DEFAULT_COLLATION
        end

        # @api private
        def show_variable(name)
          result = select('SHOW VARIABLES LIKE ?', name).first
          result ? result.send(VALUE_METHOD).freeze : nil
        end

        private

        # Return SQL statement for the text column
        #
        # @param [Integer] length
        #   the max allowed length
        #
        # @return [String]
        #   the statement to create the text column
        #
        # @api private
        def text_column_statement(length)
          if    length < 2**8  then 'TINYTEXT'
          elsif length < 2**16 then 'TEXT'
          elsif length < 2**24 then 'MEDIUMTEXT'
          elsif length < 2**32 then 'LONGTEXT'

          # http://www.postgresql.org/files/documentation/books/aw_pgsql/node90.html
          # Implies that PostgreSQL doesn't have a size limit on text
          # fields, so this param validation happens here instead of
          # DM::Property#initialize.
          else
            raise ArgumentError, "length of #{length} exceeds maximum size supported"
          end
        end

        # Return SQL statement for the integer column
        #
        # @param [Range] range
        #   the min/max allowed integers
        #
        # @return [String]
        #   the statement to create the integer column
        #
        # @api private
        def integer_column_statement(range)
          '%s(%d)%s' % [
            integer_column_type(range),
            integer_display_size(range),
            integer_statement_sign(range),
          ]
        end

        # Return the integer column type
        #
        # Use the smallest available column type that will satisfy the
        # allowable range of numbers
        #
        # @param [Range] range
        #   the min/max allowed integers
        #
        # @return [String]
        #   the column type
        #
        # @api private
        def integer_column_type(range)
          if range.first < 0
            signed_integer_column_type(range)
          else
            unsigned_integer_column_type(range)
          end
        end

        # Return the signed integer column type
        #
        # @param [Range] range
        #   the min/max allowed integers
        #
        # @return [String]
        #
        # @api private
        def signed_integer_column_type(range)
          min = range.first
          max = range.last

          tinyint   = 2**7
          smallint  = 2**15
          integer   = 2**31
          mediumint = 2**23
          bigint    = 2**63

          if    min >= -tinyint   && max < tinyint   then 'TINYINT'
          elsif min >= -smallint  && max < smallint  then 'SMALLINT'
          elsif min >= -mediumint && max < mediumint then 'MEDIUMINT'
          elsif min >= -integer   && max < integer   then 'INT'
          elsif min >= -bigint    && max < bigint    then 'BIGINT'
          else
            raise ArgumentError, "min #{min} and max #{max} exceeds supported range"
          end
        end

        # Return the unsigned integer column type
        #
        # @param [Range] range
        #   the min/max allowed integers
        #
        # @return [String]
        #
        # @api private
        def unsigned_integer_column_type(range)
          max = range.last

          if    max < 2**8  then 'TINYINT'
          elsif max < 2**16 then 'SMALLINT'
          elsif max < 2**24 then 'MEDIUMINT'
          elsif max < 2**32 then 'INT'
          elsif max < 2**64 then 'BIGINT'
          else
            raise ArgumentError, "min #{range.first} and max #{max} exceeds supported range"
          end
        end

        # Return the integer column display size
        #
        # Adjust the display size to match the maximum number of
        # expected digits. This is more for documentation purposes
        # and does not affect what can actually be stored in a
        # specific column
        #
        # @param [Range] range
        #   the min/max allowed integers
        #
        # @return [Integer]
        #   the display size for the integer
        #
        # @api private
        def integer_display_size(range)
          [ range.first.to_s.length, range.last.to_s.length ].max
        end

        # Return the integer sign statement
        #
        # @param [Range] range
        #   the min/max allowed integers
        #
        # @return [String, nil]
        #   statement if unsigned, nil if signed
        #
        # @api private
        def integer_statement_sign(range)
          puts "---in unsigned---------"
          ' ' unless range.first < 0
        end

        def supports_default_values?
          false
        end

        # @api private
        def indexes(model)
          filter_indexes(model, super)
        end

        # @api private
        def unique_indexes(model)
          filter_indexes(model, super)
        end

        # Filter out any indexes with an unindexable column in MySQL
        #
        # @api private
        def filter_indexes(model, indexes)
          field_map = model.properties(name).field_map
          indexes.select do |index_name, fields|
            fields.all? { |field| !field_map[field].kind_of?(Property::Text) }
          end
        end
      end # module SQL

      include SQL

      module ClassMethods
        # Types for MySQL databases.
        #
        # @return [Hash] types for MySQL databases.
        #
        # @api private
        def type_map
          @type_map ||= super.merge(
            DateTime => { :primitive => 'DATETIME' },
            Time     => { :primitive => 'DATETIME' }
          ).freeze
        end
      end

    end
  end
end
