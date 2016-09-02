class RequestFormatter

  def self.api_expense(user, params)
    parse_receipt params
    param = format('./app/formatter/api/expense.yaml', params)
    if param.present? and param[:expense].present?
      if param[:expense][:amount_attributes].present? and param[:expense][:amount_attributes][:value].present?
        param[:expense][:amount_attributes][:currency_id] = Currency.first.id
      end
      if param[:expense][:receipts_attributes].present?
        param[:expense][:receipts_attributes].each do |p|
          p[:user_id] = user.id
        end
      end
    end
    param
  end

  def self.format(path_to_file, params)
    map = YAML.load_file(path_to_file) rescue nil
    return nil unless map.present?
    values = extract map['from'], params
    return nil if values.blank?
    construct map['to'], values
  end

  def self.extract(config, map)
    return nil unless config.present? and map.present?
    values = {}
    config.each do |key, value|
      next if key.blank? or value.blank?
      next unless map.has_key?(key.to_s) or map.has_key?(key.to_sym)
      if value.is_a?(String)
        next unless value[0] == '#'
        values[value] = map[key.to_sym]
      elsif value.is_a?(Array)
        # todo handle array in 'to'
      elsif value.is_a?(Hash)
        res = extract config[key], (map[key.to_sym] or map[key.to_s])
        values.merge!(res) unless res.blank?
      end
    end
    values
  end

  def self.construct(config, values)
    return nil unless config.present? and values.present?
    map = {}
    config.each do |key, value|
      next if key.blank? or value.blank?
      if value.is_a?(Hash)
        res = construct config[key], values
        next if res.blank?
        map[key.to_sym] = res
      else
        if value.is_a?(String) and value[0] == '#'
          next if values[value].blank?
          map[key.to_sym] = values[value]
        elsif value.is_a?(Array)
          next if value.blank?
          v = values[value[0]]
          v = [v] unless v.is_a?(Array)
          map[key.to_sym] = v
        else
          map[key.to_sym] = value
        end
      end
    end
    map = map.deep_symbolize_keys if map.present?
    map
  end

  def self.parse_receipt(params)
    if params[:receipt].present?
      image = extract_receipt_image(params)
      params[:receipt] = {}
      params[:receipt][:image] = image
    end
  end

  def self.extract_receipt_image(params)
    data = params[:receipt]
    file = data.tempfile
    file.class.class_eval { attr_accessor :original_filename, :content_type }
    file.original_filename = params[:filename]
    file.content_type = params[:content_type]
    file
  end

end