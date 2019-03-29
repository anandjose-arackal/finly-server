require 'fuzzystringmatch'
class StringUtils

  def self.to_bool(string)
    return !!string if (!!string == string)
    # return nil unless string.kind_of?(String)
    return true if [1, 'true', '1', 'yes', 'on', 't', 'y', 'Y'].include? string
    return false if [0, 'false', '0', 'no', 'off', 'f', 'n', 'N'].include? string
    return nil
  end

  def self.force_utf_8_encoding(string)
    return string if string.nil?
    string&.encode(Encoding.find('UTF-8'), {invalid: :replace, undef: :replace, replace: ''}).force_encoding('UTF-8')
  end

  def self.titleize(text)
    text&.humanize&.gsub(/\b(?<!['’`])[a-z]/) { $&.capitalize }
  end

  def self.is_number?(string)
    true if Float(string) rescue false
  end

  def self.fuzzy_string_match(string1, string2)
    jarow = ::FuzzyStringMatch::JaroWinkler.create(:native)
    if string1.present? && string2.present? && string1.instance_of?(String) && string2.instance_of?(String)
      (jarow.getDistance( string1, string2 ) * 100).to_i
    else
      0
    end
  end



end
