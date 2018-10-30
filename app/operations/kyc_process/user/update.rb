class KycProcess::User::Update < KycProcess::User::Base
  attr_accessor :kyc_params, :user_params, :user_profile_params

  def init
    super
    self.kyc_params = kyc_strong_params
    self.user_params = user_strong_params
    self.user_profile_params = user_profile_strong_params
  end

  def process
    if self.kyc_params.present?
      unless self.individual_kyc.update(self.kyc_params)
        add_message :error, self.individual_kyc.errors.full_messages
      end
    end
    if self.user_params.present?
      unless self.individual_kyc.user.update(self.user_params)
        add_message :error, self.individual_kyc.user.errors.full_messages
      end
    end
    if self.user_profile_params.present?
      unless self.individual_kyc.user.profile.update(self.user_profile_params)
        add_message :error, self.individual_kyc.user.errors.full_messages
      end
    end
  end

  protected
  def kyc_strong_params
    return nil unless params&.dig(:individual_kyc).present?
    # params.require(:individual_kyc).permit(:id_proof, :address_proof)
    params = self.params.require(:individual_kyc).permit(:kyc_number, :kyc_2_number, :kyc_1_number, :type_id)
    ## DEPRECATED START ##
    params[:id_proof]= self.params[:individual_kyc][:id_proof] if self.params[:individual_kyc][:id_proof].present?
    params[:address_proof] = self.params[:individual_kyc][:address_proof] if self.params[:individual_kyc][:address_proof].present?
    params[:kyc_file_1]= self.params[:individual_kyc][:kyc_file_1] if self.params[:individual_kyc][:kyc_file_1].present?
    params[:kyc_file_2] = self.params[:individual_kyc][:kyc_file_2] if self.params[:individual_kyc][:kyc_file_2].present?
    params[:aadhar_front] = self.params[:individual_kyc][:aadhar_front] if self.params[:individual_kyc][:aadhar_front].present?
    params[:aadhar_back]= self.params[:individual_kyc][:aadhar_back] if self.params[:individual_kyc][:aadhar_back].present?
    ## DEPRECATED END ##

    params[:kyc_1_front] = self.params[:individual_kyc][:kyc_1_front] if self.params[:individual_kyc][:kyc_1_front].present?
    params[:kyc_1_back]= self.params[:individual_kyc][:kyc_1_back] if self.params[:individual_kyc][:kyc_1_back].present?
    params[:kyc_2_front] = self.params[:individual_kyc][:kyc_2_front] if self.params[:individual_kyc][:kyc_2_front].present?
    params[:kyc_2_back]= self.params[:individual_kyc][:kyc_2_back] if self.params[:individual_kyc][:kyc_2_back].present?
    params[:photo] = self.params[:individual_kyc][:photo] if self.params[:individual_kyc][:photo].present?
    params[:signature] = self.params[:individual_kyc][:signature] if self.params[:individual_kyc][:signature].present?

    params
  end

  def user_strong_params
    return nil unless params&.dig(:user).present?
    params.require(:user).permit(:first_name, :last_name, :mothers_maiden_name)
  end

  def user_profile_strong_params
    return nil unless params&.dig(:user, :profile).present?
    params.require(:user).require(:profile).permit(:gender, :date_of_birth, :address_1,
                                                      :address_2, :city, :state_id, :pin_code)
  end

end
