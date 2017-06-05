module SeedSnapshot
  class Configuration
    def initialize
      raise 'Support only MySQL' if adapter_name == 'Mysql2'
    end

    def adapter_name
      @adapter_name ||= ActiveRecord::Base.connection.adapter_name
    end

    def schema_version
      @schema_version ||= ActiveRecord::Migrator.current_version
    end

    def database_options
      @options ||= ActiveRecord::Base.connection.raw_connection.query_options
    end

    # /tmp/dump/123456789.sql'
    def current_version_path
      base_path.join(schema_version + '.sql')
    end

    # /tmp/dump
    def base_path
      Rails.root.join('tmp').join('dump')
    end

    def make_tmp_dir
      FileUtils.mkdir_p(base_path) if File.exists?(base_path)
    end
  end
end
