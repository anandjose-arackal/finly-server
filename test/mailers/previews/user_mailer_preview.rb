class UserMailerPreview < ActionMailer::Preview


  # http://localhost:3001/rails/mailers/user_mailer/admin_welcome
  def admin_welcome
    user = User.first
    token = "lskjdbfjkhsbdfjkhsbdf"
    UserMailer.admin_welcome(user, token)
  end

  def invite
    user = User.first
    token = "asdfsdfsadfsdf"
    UserMailer.invite(user, token, "Something")
  end
end