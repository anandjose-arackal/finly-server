class Procure::Configs::MailerController < BaseControllers::PublicBase

  def send_mail
    @result = Procurements::Mailers::SendMail.(current_user, params)
    respond
  end

end
