class Sms::UserPasswordChange < Sms::Send

  def message
    'The password for your Finly account was recently changed. If you have not changed the password, reset your password immediately'
  end

 end