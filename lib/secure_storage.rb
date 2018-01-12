class SecureStorage

  KEYS_TO_LOAD = %w(core/finly_collect core/yes_bank core/database)

  def self.load(username, password, keys = nil)
    # if Rails.env.production? or Rails.env.development?
      conn = Faraday.new(:url => 'https://35.154.145.138')
      conn.basic_auth(username, password)
      keys_to_load = keys || KEYS_TO_LOAD
      response = conn.get '/core', {keys: keys_to_load}
      puts "response status: #{response.status}"
      puts "response body: #{response.body}"
      puts "response: #{response}"
      if response.status == 200
        begin
          SimpleConfig.for :application do
            set :secure_storage, JSON.parse(response.body)&.with_indifferent_access
          end
        rescue => e
          puts "FAILED TO LOAD FROM SECURE STORAGE ( message :#{e.message} )"
        end
      else
        puts "FAILED TO LOAD FROM SECURE STORAGE ( response: #{response.status} )"
      end
    # else
    #   begin
    #     SimpleConfig.for :application do
    #       set :secure_storage, YAML.load('config/secure_storage_dev_config.yml').with_indifferent_access
    #     end
    #   rescue Exception
    #     puts 'FAILED TO LOAD FROM SECURE STORAGE'
    #   end
    # end
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