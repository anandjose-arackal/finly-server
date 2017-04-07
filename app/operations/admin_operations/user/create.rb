class AdminOperations::User::Create < AdminOperations::User::Base

  attr_accessor :company, :user

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, please try again"
    end
  end

  def init
    self.company = Company.find_by(id: params[:id])
  end

  def process
    self.user = company.users.build(user_params)
    unless user.save
      add_message :error, user.errors.full_messages
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :invitation_token, :mobile_number, :first_name,
                                 :last_name, :mothers_maiden_name,
                                 profile_attributes: [:date_of_birth, :gender, :address_1,
                                                      :address_2, :city, :state_id, :pin_code],
                                 role_mapping_attributes: [:user_role_id])
  end
end