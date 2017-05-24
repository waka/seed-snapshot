module ActiveRecord
  module Snapshot
    # dump and restore by ddl
    module DDL
      def load_tables(tables = [])
      end

      def save_tables(tables = [])
      end

      def load_db(db_name)
      end

      def save_db(db_name)
      end

      private

      def save
      end

      def load
      end
    end
  end
end
