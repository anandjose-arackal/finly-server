# action to update a particular user's details.
class User::Configuration::UpdateDetails < BaseOperation
  attr_accessor :details_params, :changes, :users, :editable_user

  def authorized_user_types
    [:employee, :company_admin]
  end

  def pre_validate
    return messages[:error] << 'No user passed' if user.blank?
    return messages[:error] << 'No params passed' if params.blank?
    return messages[:error] << 'Employee Id is not present' if params[:employee_id].blank?
    return  messages[:error] << 'Email Id is not present' if params[:email].blank?
    
    if params[:gender].present?
      if (['male', 'female'].include? (params[:gender].downcase) )
        params[:gender] = params[:gender].downcase.split("").first
      else
        return messages[:error] << 'Gender not specified correctly'
      end
    end
    
    
    if params[:status].present?
      if (['active', 'inactive'].include? (params[:status].downcase) )
        params[:status] = ( params[:status].downcase == 'active' ) ? true.to_s : false.to_s
      else
        return messages[:error] << 'Sataus not specified correctly'
      end
    end

  end

  def init
    self.users = User::Index.(current_user, params)
    if self.users.failure?
        add_message :error, "Unable to fetch user details. Please refer the API documentation or contact Finly Customer Support"
        return
    end
    
    self.editable_user = self.users&.team.find_by(email: params[:email])
    if( editable_user.blank? || (editable_user.profile&.employee_id != params[:employee_id]))
      return messages[:error] << 'User not found with the given Email Id and Employee ID' 
    end
  end

  def validate
    return if has_errors?
    unless Constants::VALID_EMAIL_FORMAT.match? ( params[:email] )
      return messages[:error] << 'Email Id is not correct format'
    end
  end

  def subscribe
    before_save self.user, &method(:regenerate_otp)
  end

  def process
    messages[:error] = editable_user.errors.full_messages unless editable_user.update_attributes(details_params)
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

    if params[:email].present?
      formatted_request = RequestFormatter::ApiParser::FmParser::V1::Users::Update.(user, params).formatted_request
      formatted_request.require(:user).permit(:first_name, :last_name, :mobile_number, :mothers_maiden_name,
                                              :department_id, :active, :location_id,
                                              profile_attributes: [:gender, :date_of_birth, :employee_id,
                                                :payroll_id, :address_1, :address_2, :city, :state_id, :pin_code])
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