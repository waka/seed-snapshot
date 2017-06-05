require 'active_record'
require 'active_support/dependencies/autoload'

module SeedSnapshot
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :Configuration
    autoload :Mysql
    autoload :Snapshot
    autoload :Version
  end

  # @param Array[ActiveRecord::Base] classes
  # @param Array[ActiveRecord::Base] ignore_classes
  # @param Boolean force_dump
  def self.dump(classes = [], ignore_classes = [], force_dump = false)
    snapshot = Snapshot.new(configuration)
    snapshot.dump(classes, ignore_classes, force_dump)
  end

  def self.restore
    snapshot = Snapshot.new(configuration)
    snapshot.restore
  end

  def self.configuration
    Configuration.new
  end
end

# error if rails did not loaded
unless defined?(Rails)
  raise 'seed-snapshot required rails.'
end
