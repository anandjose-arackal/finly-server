class BbpsReminderMailer < ApplicationMailer

  def send_mail(bill_details)
    # return unless presenter.validate
    # @data = presenter
    mail_subject = "Reminder - Payment for [Utility] Bill Due"
    mail to: bill_details, subject: mail_subject, template_name: 'template'
  end

end