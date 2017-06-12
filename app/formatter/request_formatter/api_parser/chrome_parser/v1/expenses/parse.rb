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

    email_body = params&.dig(:receipt_email)&.dig(:body)
    if email_body.present? and map&.dig(:expense)&.dig(:receipt_email_attributes).present?
      email_id = (params&.dig(:receipt_email)&.dig(:email_id) || SecureRandom.hex(6))
      name = "#{email_id}_body.txt}"
      map[:expense][:receipt_email_attributes][:body] = FakeFileIO.new(name, email_body)
    end

    # <% if params[:receipt_email][:attachments].present? %>
    # receipt_email_attachments_attributes:
    #   <% params[:receipt_email][:attachments].each do |attachment| %>
    #      - attachment_url: <%= attachment[:url] %>
    #     attachment_url_file_name: <%= attachment[:file_name] %>
    #      <% end %>
    # <% end %>

    if params[:receipt_email][:attachments].present?
      map[:expense][:receipt_email_attributes][:receipt_email_attachments_attributes] = []
      params[:receipt_email][:attachments].each do |attachment|
        map[:expense][:receipt_email_attributes][:receipt_email_attachments_attributes] << {original_attachment: attachment}
      end
    end

    Formatter.handle_api_nil map

    self.formatted_request = map
  end

end