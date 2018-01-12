class SecureStorage

  KEYS_TO_LOAD = %w(core/finly_collect core/yes_bank core/database)

  def self.load(username, password, keys = nil)
    base_url = YAML.load(File.read('config/secure_storage_config.yml'))&.dig('base_url')
    if base_url.present?
      conn = Faraday.new(:url => base_url)
      conn.basic_auth(username, password)
      keys_to_load = keys || KEYS_TO_LOAD
      response = conn.get '/core', {keys: keys_to_load}
      if response.status == 200
        begin
          SimpleConfig.for :application do
            set :secure_storage, JSON.parse(response.body)&.with_indifferent_access
          end
        rescue => e
          puts "FAILED TO LOAD FROM SECURE STORAGE ( Message :#{e.message} )"
        end
      else
        puts "FAILED TO LOAD FROM SECURE STORAGE ( Response: #{response.status} )"
      end
    else
      begin
        SimpleConfig.for :application do
          set :secure_storage, YAML.load('config/secure_storage_config.yml')
        end
      rescue => e
        puts "FAILED TO LOAD FROM SECURE STORAGE ( Local Exception : #{e.message} )"
      end
    end
  end

  def self.read(key)
    if SimpleConfig.for(:application).exists? :secure_storage
      return SimpleConfig.for(:application).secure_storage[key]
    end
  end

  def self.loaded?(key=nil)
    loaded = SimpleConfig.for(:application).exists? :secure_storage
    return loaded unless loaded and key.present?
    return !!SimpleConfig.for(:application).secure_storage[key]
  end

end