class Formatter

  def self.handle_api_nil(hash)
    hash.each do |key, value|
      if value.kind_of?(Hash)
        handle_api_nil value
      elsif value.kind_of?(Array)
        value.each do |v|
          handle_api_nil v
        end
      elsif value.is_a?(String) and value == 'nil'
        hash[key] = nil
      end
    end
    hash
  end

# Delete all null values in a hash/array
  def self.remove_blanks(item)
    if item.kind_of?(Array)
      item.each do |k, v|
        remove_blanks v if v.kind_of?(Hash)
      end
      item.compact!
    elsif item.kind_of?(Hash)
      item.each do |key, value|
        if value.kind_of?(Hash)
          remove_blanks value
        elsif value.kind_of?(Array)
          value.each do |v|
            remove_blanks v if v.kind_of?(Hash)
          end
          value.compact!
        end
      end
      item.delete_if { |k, v| v.blank? }
      return item
    end
  end

# Symbolize all keys in the hash
  def self.symbolize_hash_keys(hash)
    hash.each do |key, value|
      if value.kind_of?(Hash)
        symbolize_hash_keys value
      elsif value.kind_of?(Array)
        value.each do |v|
          symbolize_hash_keys v if v.kind_of?(Hash)
        end
      else
      end
    end
    hash.symbolize_keys!
    hash
  end

end