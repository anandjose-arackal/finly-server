class Sms::UserInvite < Sms::Base

  def message
    'You have been invited to use Finly. Please visit www.finly.io/login to set your password'
  end

end