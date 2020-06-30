class DemoMailer < ApplicationMailer
  def preview_welcome(preview_registration)
    @preview_registration = preview_registration
    mail to: preview_registration.email, subject: 'Finly: Accounts Payable at your service'
  end

  def notify_preview(preview_registration, recipient)
    @preview_registration = preview_registration
    mail to: recipient, subject: 'New demo request'
  end

  def notify_resource_download(resource_request, recipient)
    @resource_request = resource_request
    mail to: recipient, subject: "New Resource Download"
  end

  def signedup_user(signedup_user, recipient)
    @signedup_user = signedup_user
    mail to: recipient, subject: "Someone Self-Signed Up"
  end

  def product_pricing_queries(product_pricing_query, recipient)
    @product_pricing_query = product_pricing_query
    mail to: recipient, subject: "New Product Pricing Query"
  end
end
