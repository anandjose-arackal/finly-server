# sets the password for a user

class User::Login::SetPassword < BaseOperation

  attr_accessor :password_params, :selected_user

  def self.call(params)
    super(nil, params)
  end

  def pre_validate
    if params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.password_params = password_parameters
    self.selected_user = User.find_by(mobile_number: password_params[:mobile_number])
  end

  def validate
    unless selected_user
      add_message :error, "This user is not recognized"
      return
    end
    if password_params[:password].blank?
      add_message :error, "Password cannot be blank"
      return
    end
    if password_params[:password_confirmation].blank?
      add_message :error, "Password confirmation cannot be blank"
      return
    end
    if password_params[:password] != password_params[:password_confirmation]
      add_message :error, "Password and password confirmation have to match"
      return
    end
  end

  def process
    password_params.delete(:mobile_number)
    unless selected_user.update_attributes(password_params)
      messages[:error] << selected_user.errors.full_messages.to_sentence
      return
    end
    # setting verified as true for this user
    selected_user.update_attributes(verified: true, default_password: false)
  end

  def post_process
    add_message :success, 'Password set'
  end

  def success
    User::Login::SetPassword::SuccessPresenter.new(selected_user, params, messages)
  end

  class User::Login::SetPassword::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter


    def init

    end
  end


  private

  def password_parameters
    params.require(:user).permit(:password, :password_confirmation, :mobile_number)
  end
end