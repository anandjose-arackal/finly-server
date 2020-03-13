class Tally::Utils


  def self.to_date(date)
    return nil if date.blank?
    # return date if date.class.name == String.name
    date = Date.parse date if date.class.name == String.name

    date.strftime("%Y%m%d")
  end

  def self.to_bool(value)
    return "No" if value.blank? or not value
    "Yes"
  end

  def self.is_deemed_positive?(value)
    to_bool((value && value < 0))
  end

  def self.format(json, options = {})
    json.inject({}) do |new_hash, (k, v)|
      if v.nil?
        new_hash[k] = ""
      else
        new_hash[k] = v.class == Hash ? format(v, options) : v
      end
      new_hash
    end
  end

end