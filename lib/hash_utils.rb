class HashUtils

  def self.deep_reject(hash, &block)
    hash.each_with_object({}) do |(k, v), memo|
      unless block.call(k, v)
        if v.is_a?(Hash)
          memo[k] = deep_reject(v, &block)
        else
          memo[k] = v
        end
      end
    end
  end

  def self.deep_fetch(data, path, delimiter: "/", default: nil)
    keys = path.to_s.split(delimiter)
    value = data.dig(*keys) rescue default
    value.nil? ? default : value # value can be false (Boolean)
  end

    # Array DeepFetch
    # def deep_fetch(data, path, delimiter: '/', default: nil)
    #   indexes = path.to_s.split(delimiter).map(&:to_i)
    #   value = data.dig(*indexes) rescue default
    #   value.nil? ? default : value  # value can be false (Boolean)
    # end

end
