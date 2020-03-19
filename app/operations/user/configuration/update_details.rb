# action to update a particular user's details.
class User::Configuration::UpdateDetails < BaseOperation
  attr_accessor :details_params, :changes

  def authorized_user_types
    [:employee, :company_admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << 'No user or params passed'
    end
  end

  def validate
    if details_params[:name].blank? and details_params[:mobile_number].blank?
      messages[:error] << 'Nothing to update'
      # return false
    end
  end

  def subscribe
    before_save self.user, &method(:regenerate_otp)
  end

  def process
    user = User::Show.(current_user, params)&.selected_user
    messages[:error] << 'User not found with the given Employee ID' if user.blank?
    messages[:error] = user.errors.full_messages unless user.update_attributes!(details_params)
  end

  def post_process
    handle_otp
    messages[:success] << 'Details updated'
  end

  private
  def regenerate_otp(model)
    self.changes = model.changes
  end

  def details_params
    if params[:user_id].present?
      formatted_request = RequestFormatter::ApiParser::FmParser::V1::Users::Update.(user, params).formatted_request
      formatted_request.require(:user).permit(:user_id, :first_name, :last_name, :mobile_number, :mothers_maiden_name,
                  :department_id, :active, :location_id, profile_attributes: [:gender, :date_of_birth,
                  :employee_id, :payroll_id,:address_1, :address_2, :city, :state_id, :pin_code ])
    else
      params.require(:user).permit(:name, :mobile_number)
    end
  end

  def handle_otp
    return if self.changes.blank? or self.changes[:mobile_number].blank? or self.changes[:mobile_number] == user.mobile_number_was
    user.update_attributes(otp: nil, otp_sent_at: nil, otp_verified_at: nil, otp_verified: false)
    # temporarily commenting out sending the OTP implicitly because we've changed the flow
    # User::Verification::Otp::Create.(user, params)
  end
end