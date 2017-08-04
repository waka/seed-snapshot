require 'seed/configuration'
require 'seed/mysql'
require 'seed/snapshot'

module SeedSnapshot
  VERSION = "0.1.0"

  # @param Array[ActiveRecord::Base] classes
  # @param Array[ActiveRecord::Base] ignore_classes
  # @param Boolean force
  def self.dump(classes: [], ignore_classes: [], force: false)
    snapshot = Seed::Snapshot.new(self.configuration)
    snapshot.dump(classes, ignore_classes, force)
  end

  def self.restore
    snapshot = Seed::Snapshot.new(self.configuration)
    snapshot.restore
  end

  # @return Boolean
  def self.exists?
    snapshot = Seed::Snapshot.new(self.configuration)
    snapshot.exist_path?
  end

  def self.clean
    snapshot = Seed::Snapshot.new(self.configuration)
    snapshot.clean
  end

  # @return Seed::Configuration
  def self.configuration
    Seed::Configuration.new
  end
end
