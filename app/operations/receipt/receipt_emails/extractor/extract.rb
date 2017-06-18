class Receipt::ReceiptEmails::Extractor::Extract < BackgroundOperation
  # NOTE: THIS IS A BACKGROUND_OPERATION
  attr_accessor :html_body, :sender, :sent_at, :subject
  attr_accessor :amount, :currency_id, :merchant, :datetime, :note, :extracted_data

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:html_body].blank? or params[:sent_at].blank?
      add_message :error, 'Email not found'
      return
    end
  end

  def init
    self.html_body = params[:html_body]
    self.sender = params[:sender]
    self.sent_at = params[:sent_at]
    self.subject = params[:subject]
  end

  def process
    adapter = Receipt::ReceiptEmails::Extractor::Adapter::Loader.adapter_for(sender, html_body)

    if adapter.blank?
      add_message :error, 'Cannot parse email'
      return
    end
    data_presenter = adapter.(self.user, self.sender, self.sent_at, self.subject, html_body)

    if data_presenter&.success?
      self.extracted_data = data_presenter

      # If the extraction is a partial match, store the email as parsing failed in a separate db so it can be parsed in the future
      if self.extracted_data.partial_match? and Receipt::ReceiptEmails::Extractor::Adapter::Loader.known_sender?(sender)
        failure_param = {
            sender: self.sender,
            sent_at: self.sent_at,
            subject: self.subject,
            raw_html: FakeFileIO.new(self.html_body, "#{sender}_failed.html"),
            fixed: false,
            parsed_merchant: self.extracted_data.merchant,
            parsed_amount_value: self.extracted_data.amount_value,
            parsed_currency_id: self.extracted_data.currency_id,
            parsed_datetime: self.extracted_data.datetime,
            parsed_note: self.extracted_data.note,
            parsed_category_id: self.extracted_data.category_id
        }
        user.receipt_email_parse_failures.create failure_param
      end
    else
      add_message :error, 'Failed to auto extract from email'
    end
  end

  def success
    self.extracted_data
  end

end