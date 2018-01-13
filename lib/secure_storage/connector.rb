require_relative 'configuration'

module SecureStorage
  class Connector < ::SecureStorage::Configuration

    define_setting :keys
    define_setting :path, 'config/secure_storage_config.yml'
    define_setting :local, false

    def self.configuration
      super()
      self.init
    end

    def self.init
      unless SecureStorage::Connector.loaded?
        SecureStorage::Connector.load
      end
    end

    def self.load(keys_to_load = nil)
      keys_to_load = keys_to_load || SecureStorage::Connector.keys

      if SecureStorage::Connector.local
        load_from_local(keys_to_load)
      else
        load_from_server(keys_to_load)
      end
    end

    def self.read(key)
      $secure_storage_cache&.read(key)
    end

    def self.loaded?(key=nil)
      key.present? ? $secure_storage_cache&.dig(key).present? : $secure_storage_cache.present?
    end

    private
    def self.init_cache
      if $secure_storage_cache.nil?
        $secure_storage_cache = ActiveSupport::Cache::MemoryStore.new
      end
    end

    def self.load_from_server(keys_to_load)
      base_url = YAML.load(File.read(SecureStorage::Connector.path))&.dig('base_url')
      return unless base_url.present?
      conn = Faraday.new(:url => base_url)
      conn.basic_auth(ENV['SECURE_STORAGE_USERNAME'], ENV['SECURE_STORAGE_PASSWORD'])
      response = conn.get '/core', {keys: keys}
      if response.status == 200
        begin
          values = JSON.parse(response.body)&.with_indifferent_access
        rescue => e
          puts "FAILED TO LOAD FROM SECURE STORAGE ( Message :#{e.message} )"
          return
        end
      else
        puts "FAILED TO LOAD FROM SECURE STORAGE ( Response: #{response.status} )"
        return
      end
      load_config(values, keys_to_load)
    end

    def self.load_from_local(keys_to_load)
      values = nil
      begin
        values = YAML.load(File.read('config/secure_storage_config.yml'))&.with_indifferent_access
      rescue => e
        puts "FAILED TO LOAD FROM SECURE STORAGE ( Local Exception : #{e.message} )"
        return
      end
      load_config(values, keys_to_load)
    end

    def self.load_config(values, keys_to_load)
      init_cache
      keys_to_load.each do |key|
        $secure_storage_cache.write(key, values[key]) if SecureStorage::Connector.include?(key)
      end
    end
  end
end