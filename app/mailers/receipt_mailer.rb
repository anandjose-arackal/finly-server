class ReceiptMailer < ApplicationMailer

  def notify_receipt_upload(company, owner, receipt, recipient_email)
    @company = company
    @owner = owner
    @receipt = receipt
    @url = Constants::BASE_URL + "admin"
    mail to: recipient_email, subject: "New receipt to be transcribed", template_name: 'notifier'
  end

end