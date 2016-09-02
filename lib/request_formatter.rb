class RequestFormatter

  def self.api_expense(user, params)
    return nil if params.blank? or user.blank?
    format('api/expense.yaml.erb', user, params)
  end

  def self.format(path_to_file, user, params)
    return nil if params.blank?
    b = binding
    b.local_variable_set(:user, user)
    b.local_variable_set(:params, params)
    map = YAML.load(ERB.new(File.read("./app/formatter/#{path_to_file}")).result(b))
    # Load receipt seperately has yaml cannot handle images
    if params[:receipt].present?
      parse_receipt user, params
      map['expense']['receipts_attributes']= []
      map['expense']['receipts_attributes'][0] = params[:receipt]
    end
    clean_hash_new map
    symbolize_hash_keys map
    map
  end

  # Delete all null values in a hash
  def self.clean_hash_new(hash)
    hash.each do |key, value|
      if value.kind_of?(Hash)
        clean_hash_new value
      elsif value.kind_of?(Array)
        value.each do |k, v|
          clean_hash_new v if v.kind_of?(Hash)
        end
        value.compact!
      end
    end
    hash.delete_if { |k, v| v.blank? }
  end

  # Symbolize all keys in the hash
  def self.symbolize_hash_keys(hash)
    hash.each do |key, value|
      if value.kind_of?(Hash)
        symbolize_hash_keys value
      elsif value.kind_of?(Array)
        value.each do |k, v|
          symbolize_hash_keys v if v.kind_of?(Hash)
        end
      else
      end
    end
    hash.symbolize_keys!
  end

  def self.parse_receipt(user, params)
    if params[:receipt].present?
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