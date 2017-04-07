class DemoMailer < ApplicationMailer

  def preview_welcome(preview_registration)
    @preview_registration = preview_registration
    mail to: preview_registration.email, subject: 'Welcome to Finly!'
  end

  def notify_preview(preview_registration, recipient)
    @preview_registration = preview_registration
    mail to: recipient, subject: 'New demo request'
  end

  def notify_resource_download(resource_request, recipient)
    @resource_request = resource_request
    mail to: recipient, subject: "New Resource Download"
  end
end
