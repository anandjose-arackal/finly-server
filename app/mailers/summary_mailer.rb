class SummaryMailer < ApplicationMailer

  def send_admin_mail(presenter)
    return unless presenter.validate
    @data = presenter
    mail to: presenter.to, subject: presenter.subject, template_name: 'template_admin'
  end

  def send_manager_mail(presenter)
    return unless presenter.validate
    @data = presenter
    mail to: presenter.to, subject: presenter.subject, template_name: 'template_manager'
  end


end
