class BankTransfer::PaymentRequest::Spreadsheet::Base < BankTransfer::PaymentRequest::Base

  attr_accessor :view_role, :bank_payment_requests,
                :headers, :field_configurations, :include_attachments

  def validate
    if self.bank_payment_requests.empty?
      add_message :error, 'No payment orders passed'
      return
    end
  end

  def post_process
    BankTransfer::PaymentRequest::Spreadsheet::DownloadProcessor.call_async(user.id,
                                                                            bank_payment_requests_id: bank_payment_requests.pluck(:id), include_attachments: self.include_attachments)
    add_message :success, 'You will receive the download link in an email in the next 5 - 10 minutes'
  end

end