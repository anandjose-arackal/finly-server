class Procure::Configs::MailerController < BaseControllers::WebBase

  def send_mail
    @result = Procurements::Mailers::SendMail.(current_user, params)
    respond
  end

end
