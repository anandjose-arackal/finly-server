class User::Password::Base < BaseOperation

  attr_accessor :selected_user

  def pre_validate
    if params.blank?
      add_message :error, "Invalid input, please try again"
    end
  end

  def init
    # find the registered user via the mobile number entered
    self.selected_user = User.find_by(mobile_number: params[:mobile_number])
  end
end