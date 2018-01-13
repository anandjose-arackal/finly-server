require_relative 'configuration'

module SecureStorage
  class Connector < ::SecureStorage::Configuration

    # define_setting is used to define class static variables ( one instance across application, not just request )
    define_setting :cache, ActiveSupport::Cache::MemoryStore.new
    define_setting :keys
    define_setting :path, 'config/secure_storage_config.yml'

    def self.configuration
      super()
      self.init
    end

    def self.init
      SecureStorage::Connector.load
    end

    def self.load
      return if SecureStorage::Connector.loaded? or SecureStorage::Connector.keys.nil?
      # Load only if the require key has not yet been loaded previously
      config = YAML.load(File.read(SecureStorage::Connector.path))&.with_indifferent_access
      if !!config&.dig(:local)
        load_config(config)
      else
        load_from_server(config)
      end
    end

    def self.read(key)
      SecureStorage::Connector.cache&.read(key)
    end

    def self.loaded?
      !!self.read(:initialized)
    end

    private
    def self.load_from_server(config)
      base_url = config&.dig('base_url')
      return unless base_url.present?
      conn = Faraday.new(:url => base_url)
      conn.basic_auth(ENV['SECURE_STORAGE_USERNAME'], ENV['SECURE_STORAGE_PASSWORD'])
      response = conn.get '/core', {keys: SecureStorage::Connector.keys}
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
      load_config(values)
    end

    def self.load_config(values)
      SecureStorage::Connector.keys.each do |key|
        SecureStorage::Connector.cache.write(key, values[key])
      end
      SecureStorage::Connector.cache.write(:initialized, true)
    end
  end
end