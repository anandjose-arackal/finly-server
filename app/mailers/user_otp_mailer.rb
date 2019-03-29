class UserOtpMailer < ApplicationMailer

  def send_mail(presenter)

    @email = presenter.to
    @otp = presenter.otp
    @user_agent = presenter.user_agent
    @ip = presenter.ip
    @timestamp = presenter.timestamp

    mail to: presenter.to, subject: presenter.subject, template_name: 'template'
  end

end