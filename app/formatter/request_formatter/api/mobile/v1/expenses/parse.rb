class RequestFormatter::Api::Mobile::V1::Expenses::Parse < RequestFormatter::Base

  def validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank?
      add_message :error, 'Error loading configuration'
    end
  end

  def process
    map = format_file(__dir__, 'expense.yaml.erb', user, params)

    # Load receipt seperately has yaml cannot handle images
    if params[:receipt].present?
      RequestFormatter::Receipts::Parse.(user, params)
      if params[:receipt].present?
        map[:expense] = {} if map[:expense].blank?
        receipt = params[:receipt]
        receipt = nil if receipt == 'nil'
        map[:expense][:receipts_attributes]= []
        map[:expense][:receipts_attributes][0] = receipt
      end
    end

    if params[:custom_fields].present?
      if params[:custom_fields].kind_of?(String)
        map[:custom_fields] = JSON.parse params[:custom_fields]
      else
        map[:custom_fields] = params[:custom_fields]
      end
    end

    Formatter.handle_api_nil map

    self.params = map
  end

end