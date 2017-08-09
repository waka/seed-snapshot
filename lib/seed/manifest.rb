require 'json'

module Seed
  class Manifest
    def initialize(configuration)
      @configuration = configuration
      @paths = []
    end

    def appends(paths = [])
      @paths << paths
      @paths.flatten!
    end

    def diff?
      self.current.hash != self.latest.hash
    end

    def save
      open(self.manifest_path, File::WRONLY | File::CREAT) do |io|
        JSON.dump(self.current, io)
      end
    end

    # @return [Hash]
    def current
      @current ||= self.generate_manifest
    end

    # @return [Hash]
    def latest
      open(self.manifest_path, File::RDONLY | File::CREAT) do |io|
        JSON.load(io) rescue {}
      end
    end

    def manifest_path
      @configuration.base_path.join('seed_manifest.json')
    end

    def generate_manifest
      hash = {}
      @paths.each do |path|
        next unless File.exist?(path)
        content = File.read(path)
        hash[path] = Digest::SHA256.new.update(content).hexdigest
      end
      hash
    end
  end
end
