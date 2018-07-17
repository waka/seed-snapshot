module Seed
  class Snapshot
    def initialize(configuration)
      @configuration = configuration
    end

    def dump(classes = [], ignore_classes = [], force_dump = false)
      @configuration.make_tmp_dir

      if exist_path? && !force_dump
        puts 'Dump file already exists for current schema.'
        return
      end

      Mysql.dump(
        @configuration.current_version_path,
        options.merge({
          tables: tables(classes),
          ignore_tables: ignore_tables(ignore_classes)
        })
      )
    end

    def restore
      @configuration.make_tmp_dir

      unless exist_path?
        puts "Dump file does not exist for current schema."
        return
      end

      Mysql.restore(
        @configuration.current_version_path,
        options
      )
    end

    def clean
      unless exist_path?
        puts "Dump file does not exist for current schema."
        return
      end

      version_path = @configuration.current_version_path
      File.delete(version_path)
    end

    def exist_path?
      version_path = @configuration.current_version_path
      File.exist?(version_path)
    end

    def options
      db = @configuration.database_options
      {
        username: db[:username],
        password: db[:password],
        host:     db[:host],
        port:     db[:port],
        database: db[:database]
      }
    end

    def tables(classes)
      db = @configuration.database_options[:database]
      classes.map do |cls|
        "#{db}.#{cls.table_name}"
      end
    end

    def ignore_tables(classes)
      db = @configuration.database_options[:database]
      tables(classes).push("#{db}.schema_migrations")
    end
  end
end
