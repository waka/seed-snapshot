require 'active_record'

require 'seed/configuration'
require 'seed/mysql'
require 'seed/snapshot'

module SeedSnapshot
  VERSION = "0.1.0"

  # @param Array[ActiveRecord::Base] classes
  # @param Array[ActiveRecord::Base] ignore_classes
  # @param Boolean force_dump
  def self.dump(classes = [], ignore_classes = [], force_dump = false)
    snapshot = Seed::Snapshot.new(configuration)
    snapshot.dump(classes, ignore_classes, force_dump)
  end

  def self.restore
    snapshot = Seed::Snapshot.new(configuration)
    snapshot.restore
  end

  def self.configuration
    Seed::Configuration.new
  end
end
