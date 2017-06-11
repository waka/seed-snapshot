module Seed
  class Mysql
    def dump(file_path, username:, password:, host:, port:, database:, tables:, ignore_tables:)
      cmd = "MYSQL_PWD=#{password} mysqldump -u #{username} -h #{host} #{database} -t #{allow_tables_option(database, tables)} #{ignore_tables_option(database, ignore_tables)} > #{file_path}"
      system cmd
    end

    def restore(file_path, username:, password:, host:, port:, database:)
      cmd = "MYSQL_PWD=#{password} mysql -u #{username} -h #{host} #{database} < #{file_path}"
      system cmd
    end

    def allow_tables_option(database, tables)
      tables.map { |table| "#{database}.#{table}" }.join(' ')
    end

    def ignore_tables_option(database, tables)
      tables.map { |table| "--ignore-table=#{database}.#{table}" }.join(' ')
    end
  end
end
