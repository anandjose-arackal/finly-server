class ReceiptEmail::Extrator::Extract < ReceiptEmail::Base
  # NOTE: THIS IS A BACKGROUND_OPERATION
  attr_accessor :amount, :currency_id, :merchant, :datetime, :note, :expense_data_extract

  def process
    html_body = nil
    sender = self.receipt_email.sender
    self.datetime = self.receipt_email.sent_at
    self.note = self.receipt_email.subject

    if self.receipt_email.raw_html.present?
      html_body = self.receipt_email.raw_html
    elsif self.receipt_email.original_source.present?
      email = Mail.read_from_string(File.read(self.receipt_email.original_source.path))
      html_body = email.html_part.body.decoded
    end

    adapter = ReceiptEmail::Extractor::Adapter::Loader.adapter_for(sender, html_body)

    data_presenter = adapter.(self.receipt_email, html_body)

    if data_presenter&.success?
      data = data_presenter.extracted_data
      self.expense_data_extract = data.save_data_extract(self.receipt_email)
    end
  end

  def success
    params[:expense_data_extract] = self.expense_data_extract
    params[:receipt_email] = self.receipt_email
    ReceiptEmail::ExtractData::ExtractedData.new(user, params, messages)
  end

  class ReceiptEmail::ExtractData::ExtractedData < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :receipt_email, :expense_data_extract

    def init
      self.receipt_email = params[:receipt_email]
      self.expense_data_extract = params[:expense_data_extract]
    end
  end

end