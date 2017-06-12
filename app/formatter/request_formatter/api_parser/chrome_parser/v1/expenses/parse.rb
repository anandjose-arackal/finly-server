class RequestFormatter::ApiParser::ChromeParser::V1::Expenses::Parse < RequestFormatter::ApiParser::MobileParser::V1::Expenses::Parse

  def process
    map = format_file(__dir__, 'expense.yaml.erb', user, params)

    # Load receipt seperately has yaml cannot handle images
    if params[:receipt].present?
      formatted_params = RequestFormatter::ReceiptsParser::Parse.(user, params).formatted_request
      map[:expense] = {} if map[:expense].blank?
      receipt = formatted_params[:receipt]
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

    self.formatted_request = map
  end

end