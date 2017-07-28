class Admin::Cards::AssignRequests::Update < Admin::Cards::AssignRequests::Base
  attr_accessor :kyc_params, :user_params, :user_profile_params, :selected_user, :card_assign_request, :individual_kyc

  def pre_validate
    super
    return if has_errors?
    unless user.verifier?
      add_message :error, 'You do have the required permission to perform this action'
      return
    end
  end

  def init
    super
    self.kyc_params = kyc_strong_params
    self.user_params = user_strong_params
    self.user_profile_params = user_profile_strong_params

    self.card_assign_request = self.card_assign_requests&.first
    self.selected_user = self.card_assign_request&.card_owner
    self.individual_kyc = self.selected_user&.individual_kyc
  end

  def process
    if self.kyc_params.present?
      unless self.individual_kyc.update(self.kyc_params)
        add_message :error, self.individual_kyc.errors.full_messages
      end
    end
    if self.user_params.present?
      unless self.selected_user.update(self.user_params)
        add_message :error, self.individual_kyc.user.errors.full_messages
      end
    end
    if self.user_profile_params.present?
      unless self.selected_user.profile.update(self.user_profile_params)
        add_message :error, self.individual_kyc.user.errors.full_messages
      end
    end
  end

  protected
  def kyc_strong_params
    return nil unless params&.dig(:individual_kyc).present?
    # params.require(:individual_kyc).permit(:id_proof, :address_proof)
    params = self.params.require(:individual_kyc).permit(:kyc_number, :type_id)
    ## DEPRECATED START ##
    params[:id_proof]= self.params[:individual_kyc][:id_proof] if self.params[:individual_kyc][:id_proof].present?
    params[:address_proof] = self.params[:individual_kyc][:address_proof] if self.params[:individual_kyc][:address_proof].present?
    ## DEPRECATED END ##
    if self.params[:individual_kyc][:type_name].present?
      params[:type_id] = IndividualKycType.id_for(self.params[:individual_kyc][:type_name])
    end
    params[:kyc_file_1]= self.params[:individual_kyc][:kyc_file_1] if self.params[:individual_kyc][:kyc_file_1].present?
    params[:kyc_file_2] = self.params[:individual_kyc][:kyc_file_2] if self.params[:individual_kyc][:kyc_file_2].present?
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