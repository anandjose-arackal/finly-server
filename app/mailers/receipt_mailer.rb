class ReceiptMailer < ApplicationMailer

  def notify_receipt_upload(company, owner, receipt, recipient_email)
    @company = company
    @owner = owner
    @receipt = receipt
    @url = "www.finly.io/" + "admin"
    mail to: recipient_email, subject: "New receipt to be transcribed", template_name: 'notifier'
  end

end