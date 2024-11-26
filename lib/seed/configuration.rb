require 'digest'
require 'active_record'

module Seed
  class Configuration
    def initialize
      # error if adapter is not mysql
      raise 'seed-snapshot support only MySQL' unless adapter_name == 'Mysql2'
    end

    def adapter_name
      @adapter_name ||= ActiveRecord::Base.connection.adapter_name
    end

    def schema_version
      @schema_version ||= Digest::SHA1.hexdigest(get_all_versions.sort.join)
    end

    def client_version
      @client_version ||= ActiveRecord::Base.connection.raw_connection.info[:version]
    end

    def database_options
      @options ||= ActiveRecord::Base.connection.raw_connection.query_options
    end

    # ${Rails.root}/tmp/dump
    def base_path
      Pathname.new(Dir.pwd).join('tmp').join('dump')
    end

    # ${Rails.root}/tmp/dump/123456789.sql'
    def current_version_path
      base_path.join(schema_version.to_s + '.sql')
    end

    def make_tmp_dir
      FileUtils.mkdir_p(base_path) unless File.exist?(base_path)
    end

    private

    def get_all_versions
      if ::Gem::Version.new(::ActiveRecord::VERSION::STRING) >= ::Gem::Version.new('7.1')
        migration_paths = ::ActiveRecord::Migrator.migrations_paths
        ::ActiveRecord::MigrationContext.new(migration_paths).get_all_versions
      elsif ::Gem::Version.new(::ActiveRecord::VERSION::STRING) >= ::Gem::Version.new('6.0')
        migration_paths = ::ActiveRecord::Migrator.migrations_paths
        ::ActiveRecord::MigrationContext.new(migration_paths, ::ActiveRecord::SchemaMigration).get_all_versions
      elsif ::Gem::Version.new(::ActiveRecord::VERSION::STRING) >= ::Gem::Version.new('5.2')
        migration_paths = ::ActiveRecord::Migrator.migrations_paths
        ::ActiveRecord::MigrationContext.new(migration_paths).get_all_versions
      else
        ::ActiveRecord::Migrator.get_all_versions
      end
    end
  end
end
