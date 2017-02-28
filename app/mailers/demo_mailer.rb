class DemoMailer < ApplicationMailer

  def preview_welcome(preview_registration)
    @preview_registration = preview_registration
    mail to: preview_registration.email, subject: 'Welcome to Finly!'
  end

  def notify_preview(preview_registration, recipient)
    @preview_registration = preview_registration
    mail to: recipient, subject: 'New demo request'
  end
end
