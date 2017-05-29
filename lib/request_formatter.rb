class RequestFormatter

  def self.api_expense(user, params)
    return nil if params.blank? or user.blank?
    map = format('api/expense.yaml.erb', user, params)
    # Load receipt seperately has yaml cannot handle images
    if params[:receipt].present?
      parse_receipt user, params
      return map if params[:receipt].blank?
      map[:expense] = {} if map[:expense].blank?
      receipt = params[:receipt]
      receipt = nil if receipt == 'nil'
      map[:expense][:receipts_attributes]= []
      map[:expense][:receipts_attributes][0] = receipt
    end

    if params[:custom_fields].present?
      if params[:custom_fields].kind_of?(String)
        map[:custom_fields] = JSON.parse params[:custom_fields]
      else
        map[:custom_fields] = params[:custom_fields]
      end
    end
    Formatter.handle_api_nil map
    map
  end

  def self.api_receipt(user, params)
    return nil if params.blank? or user.blank?
    parse_receipt user, params if params[:receipt].present?
  end

  def self.format(path_to_file, user, params)
    return nil if params.blank?


    if params[:locations].present? and params[:locations].is_a?(String)
      params[:locations] = JSON.parse params[:locations]
    end

    map = YamlUtils.load_yaml_erb("./app/formatter/#{path_to_file}", {user: user, params: params})
    # Was crashing when note had a new line break. Fix was to remove it from YAML and add it here
    map['expense']['note'] = params[:note] if map.dig('expense') and params.dig(:note)
    Formatter.remove_blanks map
    Formatter.symbolize_hash_keys map
    map
  end

  def self.parse_receipt(user, params)
    if params[:receipt].present? and not params[:receipt] == 'nil'
      image = extract_receipt_image(params)
      params[:receipt] = {}
      params[:receipt][:image] = image
      params[:receipt][:user_id] = user.id
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
