class KycProcess::User::Update < KycProcess::User::Base
  attr_accessor :kyc_params, :update_user

  def pre_validate
    if user.blank? or params&.dig(:id).blank?
      add_message :error, 'User not found'
    end
  end

  def init
    self.update_user = User::Show.(user, params)&.selected_user
    return if self.update_user.blank?
    self.individual_kyc = self.update_user.individual_kyc
    self.kyc_params = kyc_strong_params
  end

  def process
    unless self.individual_kyc.update(self.kyc_params)
      add_message :error, self.individual_kyc.errors.full_messages
    end
  end

  def post_process
    if self.individual_kyc.id_proof.present? and self.individual_kyc.pan_card.present?
      self.individual_kyc.update(kyc_status_id: KycStatus.id_for(:processing))
    else
      self.individual_kyc.update(kyc_status_id: KycStatus.id_for(:incomplete))
    end
  end

  protected
  def kyc_strong_params
    params.require(:individual_kyc).permit(:id_proof, :pan_card)
  end

end