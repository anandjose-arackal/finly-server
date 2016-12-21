# action to update a particular user's details.

class User::Configuration::UpdateDetails < BaseOperation
  attr_accessor :details_params, :changes

  def authorized_user_types
    [:employee]
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
    unless user.update_attributes(details_params)
      messages[:error] = user.errors.full_messages
    end
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
    params.require(:user).permit(:name, :mobile_number)
  end

  def handle_otp
    return if self.changes.blank? or self.changes[:mobile_number].blank? or self.changes[:mobile_number] == user.mobile_number_was
    user.update_attributes(otp: nil, otp_sent_at: nil, otp_verified_at: nil, otp_verified: false)
    User::Verification::Otp::Create.(user, params)
  end

end