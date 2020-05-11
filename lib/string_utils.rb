require 'fuzzystringmatch'
class StringUtils

  TRUE_VALUES = [1, 'true', 'TRUE', true, '1', 'yes', 'on', 't', 'T', 'y', 'Y'].to_set
  FALSE_VALUES = [0, 'false', 'FALSE', false, '0', 'no', 'off', 'f', 'F', 'n', 'N', nil].to_set
  BOOLEAN_VALUES = (TRUE_VALUES + FALSE_VALUES).freeze

  def self.to_bool(string)
    return !!string if (!!string == string)
    # return nil unless string.kind_of?(String)
    return true if TRUE_VALUES.include? string
    return false if FALSE_VALUES.include? string
    return nil
  end

  def self.force_utf_8_encoding(string)
    return string if string.nil?
    string&.encode(Encoding.find('UTF-8'), {invalid: :replace, undef: :replace, replace: ''}).force_encoding('UTF-8')
  end

  def self.titleize(text)
    text&.humanize&.gsub(/\b(?<!['’`])[a-z]/) {$&.capitalize}
  end

  def self.is_number?(string)
    true if Float(string) rescue false
  end

  def self.generic_business_keywords
    [
        # /\bpvt\b/, /\bprivate\b/, /\blimited\b/, /\bltd\b/, /\bmrs\b/, /\bms\b/, /\bmiss\b/,
        # /\bmr\b/,
        # /\btech\b/, /\btechnology\b/, /\bindia\b/, /\bsolution\b/, /\bsolutions\b/,
        # /\bservice\b/, /\bservices\b/, /\bco\b/, /\bconsultant\b/, /\bconsultants\b/,
        # /\benterprises\b/, /\bnetworks\b/, /\bnetwork\b/, /\bbusiness\b/,
        # /\bconsultancy\b/, /\bcorporate\b/, /\bsystems\b/, /\bllp\b/,
        '.', '\\', '(', ')', '/', '-'
    ]
  end

  def self.clear_generic_keywords(string)
    return nil if string.nil?

    response = string&.downcase
    #Regexp.union words.map {|w| /\b(#{Regexp.escape(w)})\b/}
    generic_business_keywords.each {|keyword| response.gsub!(keyword, "")}
    response.gsub!("  ", " ")
    response.strip
  end

  def self.fuzzy_string_match(string1, string2)
    jarow = ::FuzzyStringMatch::JaroWinkler.create(:native)
    if string1.present? && string2.present? && string1.instance_of?(String) && string2.instance_of?(String)
      (jarow.getDistance(string1&.downcase, string2&.downcase) * 100).to_i
    else
      0
    end
  end

end
