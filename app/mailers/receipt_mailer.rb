class ReceiptMailer < ApplicationMailer

  def notify_receipt_upload(company, owner, receipt, recipient_email)
    @company = company
    @owner = owner
    @receipt = receipt
    mail to: recipient_email, subject: "New receipt to be transcribed", template: 'notifier'
  end
end