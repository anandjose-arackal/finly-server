class KycProcess::User::Update < KycProcess::User::Base
  attr_accessor :kyc_params, :update_user

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