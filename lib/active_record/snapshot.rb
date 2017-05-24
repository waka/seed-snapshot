require 'active_record/snapshot/ddl'
require 'active_record/snapshot/version'

module ActiveRecord
  module Snapshot
    def schema_version
      @schema_version ||= ActiveRecord::Migrator.current_version
    end

    def check_version?
    end

    def restore(tables = [])
    end

    def dump(tables = [])
    end
  end
end
