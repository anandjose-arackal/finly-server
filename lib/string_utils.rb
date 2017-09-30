class StringUtils

  def self.to_bool(string)
    return string if (!!string == string)
    return nil unless string.kind_of?(String)
    return true if ['true', '1', 'yes', 'on', 't'].include? string
    return false if ['false', '0', 'no', 'off', 'f'].include? string
    return nil
  end

  def self.force_utf_8_encoding(string)
    string&.encode(Encoding.find('UTF-8'), {invalid: :replace, undef: :replace, replace: ''}).force_encoding('UTF-8')
  end

  def self.titleize(text)
    text&.humanize&.gsub(/\b(?<!['’`])[a-z]/) { $&.capitalize }
  end

  def self.is_number?(string)
    true if Float(string) rescue false
  end

end
