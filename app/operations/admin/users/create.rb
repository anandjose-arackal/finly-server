class Admin::Users::Create < Admin::Users::Base

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
    created_user.skip_confirmation_notification!
    if created_user.save
      created_user.activate
      created_user.update_attribute(:verified, true)
      created_user.otp_verified
    else
      add_message :error, created_user.errors.full_messages
      return
    end
  end

  def post_process
    add_message :error, "User created"
  end

  def success
    Admin::Users::Base::UserPresenter.new(user, {created_user: created_user}, messages)
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