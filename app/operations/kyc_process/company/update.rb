class KycProcess::Company::Update < KycProcess::Company::Base
  attr_accessor :kyc_params

  def init
    self.kyc_params = kyc_strong_params
  end

  def process
    unless self.company_kyc.update(self.kyc_params)
      add_message :error, self.company_kyc.errors.full_messages
    end
  end

  def post_process
    if self.company_kyc.coi.present? and self.company_kyc.pan_card.present?
      self.company_kyc.update(kyc_status_id: KycStatus.id_for(:processing))
    else
      self.company_kyc.update(kyc_status_id: KycStatus.id_for(:incomplete))
    end
  end

  protected
  def kyc_strong_params
    params.require(:company_kyc).permit(:coi, :pan_card)
  end

end