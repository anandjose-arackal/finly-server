class PaymentOrderDownloadMailer < ApplicationMailer

  def send_mail(presenter)
    return unless presenter.validate
    @data = presenter
  end
end