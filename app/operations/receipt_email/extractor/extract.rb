class ReceiptEmail::Extractor::Extract < ReceiptEmail::Base
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
    adapter = ReceiptEmail::Extractor::Adapter::Loader.adapter_for(sender, html_body)

    if adapter.blank?
      add_message :error, 'Cannot parse email'
      return
    end
    data_presenter = adapter.(self.receipt_email, html_body)

    if data_presenter&.success?
      self.extracted_data = data_presenter
    else
      add_message :error, 'Failed to auto extract from email'
    end
  end

  def success
    self.extracted_data
  end

end