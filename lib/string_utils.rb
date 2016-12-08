class StringUtils

  def self.to_bool(string)
    return nil unless string.kind_of?(String)
    return true if ['true', '1', 'yes', 'on', 't'].include? string
    return false if ['false', '0', 'no', 'off', 'f'].include? string
    return nil
  end

end
