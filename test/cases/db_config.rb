require 'config'

require 'active_record'
require 'seed-snapshot'

require 'support/config'
require 'support/connection'
require 'support/mysql_client'

# MySQL が起動直後（docker compose up -d 直後など）で接続を受け付けられない場合に、しばらく待つ
def wait_for_connection(timeout: 30)
  deadline = Time.now + timeout
  begin
    ActiveRecord::Base.connection.verify!
  rescue ActiveRecord::ConnectionNotEstablished
    raise if Time.now > deadline
    puts 'Waiting for MySQL to accept connections...'
    sleep 1
    retry
  end
end

# create database if it doesn't exist
def create_database_if_not_exists
  ARTest.connection_config.each do |_, config|
    begin
      ActiveRecord::Base.establish_connection(config.except('database'))
      wait_for_connection
      ActiveRecord::Base.connection.create_database(config['database'], charset: config['encoding'], collation: config['collation'])
    rescue ActiveRecord::DatabaseAlreadyExists
      # Database already exists, nothing to do
    rescue => e
      raise "Failed to create database '#{config['database']}': #{e.message}"
    ensure
      ActiveRecord::Base.remove_connection
    end
  end
end

create_database_if_not_exists

# connect to the database
ARTest.connect

def load_schema
  original_stdout = $stdout
  $stdout = StringIO.new

  load SCHEMA_ROOT + '/schema.rb'
ensure
  $stdout = original_stdout
end

load_schema
