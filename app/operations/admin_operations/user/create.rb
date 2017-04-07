class AdminOperations::User::Create < AdminOperations::User::Base

  attr_accessor :company, :created_user

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, please try again"
    end
  end

  def init
    id = params[:id] || params[:company_id]
    self.company = Company.find_by(id: id)
  end

  def process
    self.created_user = company.users.build(user_params)
    unless created_user.save
      add_message :error, user.errors.full_messages
    end
  end

  def success
    AdminOperations::User::Base::UserPresenter.new(user, {created_user: created_user}, messages)
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