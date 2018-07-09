class Procure::Configs::MailerController < ApplicationController

  def send_mail
    @result = Procurements::Mailers::SendMail.(current_user, params)
    respond
  end

end