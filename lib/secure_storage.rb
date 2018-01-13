class SecureStorage

  KEYS_TO_LOAD = %w(core/finly_collect core/yes_bank core/database)

  def self.load(username, password, keys = nil)
    if $secure_storage_cache.nil?
      $secure_storage_cache = ActiveSupport::Cache::MemoryStore.new
    end
    base_url = YAML.load(File.read('config/secure_storage_config.yml'))&.dig('base_url')
    keys_to_load = keys || KEYS_TO_LOAD
    if base_url.present?
      conn = Faraday.new(:url => base_url)
      conn.basic_auth(username, password)
      response = conn.get '/core', {keys: keys_to_load}
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
    else
      begin
        values = YAML.load(File.read('config/secure_storage_config.yml'))&.with_indifferent_access
      rescue => e
        puts "FAILED TO LOAD FROM SECURE STORAGE ( Local Exception : #{e.message} )"
        return
      end
    end
    keys_to_load.each do |key|
      $secure_storage_cache.write(key, values[key])
    end
  end

  def self.read(key)
    $secure_storage_cache&.read(key)
  end

  def self.loaded?(key=nil)
    key.present? ? $secure_storage_cache&.dig(key).present? : $secure_storage_cache.present?
  end

end