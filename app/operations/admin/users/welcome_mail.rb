class Admin::Users::WelcomeMail < Admin::Base

  attr_accessor :selected_user, :raw_token

  def init
    id = params[:id] || params[:user_id]
    self.selected_user = User.find_by(id: id)
  end

  def validate
    unless selected_user
      add_message :error, "User not found"
      return
    end
    unless selected_user&.default_password
      add_message :error, "This user has already changed their default passsword"
    end
  end

  def process
    raw, enc = Devise.token_generator.generate(User, :reset_password_token)
    self.raw_token = raw
    selected_user.update_attribute(:reset_password_token, enc)
    selected_user.update_attribute(:reset_password_sent_at, DateUtils.local_date_time)
  end

  def post_process
    UserMailer.delay.admin_welcome(selected_user, raw_token)
  end
end