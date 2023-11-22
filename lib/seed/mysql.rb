module Seed
  class Mysql
    def self.dump(file_path, username:, password:, host:, port:, database:, tables:, ignore_tables:, client_version:)
      host = 'localhost' unless host

      additional_options =
        if client_version.match?(/\A8/)
          '--skip-column-statistics'
        else
          ''
        end

      cmd = "MYSQL_PWD=#{password} mysqldump -u #{username} -h #{host} -P #{port} #{database} -t #{allow_tables_option(tables)} #{ignore_tables_option(ignore_tables)} --no-tablespaces #{additional_options} > #{file_path}"
      system cmd
    end

    def self.restore(file_path, username:, password:, host:, port:, database:)
      host = 'localhost' unless host
      cmd = "MYSQL_PWD=#{password} mysql -u #{username} -h #{host} -P #{port} #{database} < #{file_path}"
      system cmd
    end

    def self.allow_tables_option(tables)
      tables.join(' ')
    end

    def self.ignore_tables_option(tables)
      tables.map { |table| "--ignore-table=#{table}" }.join(' ')
    end
  end
end
