module ActiveRecord
  module Snapshot
    module Mysql
      def dump(username:, password:, database:, file_path:)
        cmd = "MYSQL_PWD=#{password} mysqldump -u#{username} #{database} -t --ignore-table=#{ignore_table(database)} > #{file_path}"
        system cmd
      end

      def restore(file_path:)
        cmd = "MYSQL_PWD=#{password} mysql -u#{username} #{database} < #{file_path}"
        system cmd
      end

      def ignore_table(database)
        "#{database}.schema_migrations"
      end
    end
  end
end

