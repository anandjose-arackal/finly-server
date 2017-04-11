class Admin::Users::Update < Admin::Users::Base

  attr_accessor :company, :selected_user, :roles_to_be_removed, :roles_to_be_added

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, please try again"
    end
  end

  def init
    id = params[:id] || params[:user_id]
    self.selected_user = User.find_by(id: id)
  end

  def authorize

  end

  def pre_process

  end

  def process
    if selected_user.update(user_params)
      add_message :success, "User updated"
    else
      add_message :error, selected_user.errors.full_messages
      return
    end
  end


  def success
    Admin::Users::Base::UserPresenter.new(user, {selected_user: selected_user}, messages)
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :mothers_maiden_name,
                                 profile_attributes: [:date_of_birth, :gender, :address_1,
                                                      :address_2, :city, :state_id, :pin_code])

  end

end