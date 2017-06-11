module Seed
  class Mysql
    def self.dump(file_path, username:, password:, host:, port:, database:, tables:, ignore_tables:)
      cmd = "MYSQL_PWD=#{password} mysqldump -u #{username} -h #{host} #{database} -t #{allow_tables_option(tables)} #{ignore_tables_option(ignore_tables)} > #{file_path}"
      system cmd
    end

    def self.restore(file_path, username:, password:, host:, port:, database:)
      cmd = "MYSQL_PWD=#{password} mysql -u #{username} -h #{host} #{database} < #{file_path}"
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
