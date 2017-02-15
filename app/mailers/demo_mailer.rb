class DemoMailer < ApplicationMailer

  def preview_welcome(preview_registration)
    @preview_registration = preview_registration
    mail to: preview_registration.email, subject: 'Welcome to Finly!'
  end

  def notify_preview(preview_registration)
    @preview_registration = preview_registration
    mail to: Constants::PRODUCT_DEMO_EMAIL_ID, subject: 'New demo request'
  end
end
