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

  # http://localhost:3001/rails/mailers/user_mailer/agreements_mail
  def agreements_mail
    user = User.first
    token = EmailAuthorization.first.token
    UserMailer.agreements_mail(user, token)
  end
end