class KycProcess::User::Update < KycProcess::User::Base
  attr_accessor :kyc_params

  def init
    super
    self.kyc_params = kyc_strong_params
  end

  def process
    debugger
    unless self.individual_kyc.update(self.kyc_params)
      add_message :error, self.individual_kyc.errors.full_messages
    end
  end

  def post_process
    if self.individual_kyc.id_proof.present? and self.individual_kyc.address_proof.present?
      self.individual_kyc.update(kyc_status_id: KycStatus.id_for(:processing))
    else
      self.individual_kyc.update(kyc_status_id: KycStatus.id_for(:incomplete))
    end
  end

  protected
  def kyc_strong_params
    # params.require(:individual_kyc).permit(:id_proof, :address_proof)
    params = {}
    params[:id_proof]= self.params[:individual_kyc][:id_proof] if self.params[:individual_kyc][:id_proof].present?
    params[:address_proof] = self.params[:individual_kyc][:address_proof] if self.params[:individual_kyc][:address_proof].present?
    params
  end

end