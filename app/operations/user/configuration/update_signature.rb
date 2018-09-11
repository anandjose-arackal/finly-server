class User::Configuration::UpdateSignature < BaseOperation

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    unless user.present?
      messages[:error] << 'User not found'
      return
    end
    unless params.present? and params[:user].present?
      messages[:error] << 'Error uploading signature'
      return
    end
  end

  def process
    profile = user.profile
    profile.assign_attributes(signature_params)

    unless profile.save
      add_message :error, profile.errors.full_messages
    end
  end

  def post_process
    add_message :success, 'Successfully Updated Signature'
  end

  private
  def signature_params
    params.require(:user).permit(:signature, :signature_title)
  end

end