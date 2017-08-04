require 'config'

require 'active_record'
require 'seed-snapshot'

require 'support/config'
require 'support/connection'

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
