class KycProcess::User::Update < KycProcess::User::Base
  attr_accessor :kyc_params

  def init
    super
    self.kyc_params = kyc_strong_params
  end

  def process
    unless self.individual_kyc.update(self.kyc_params)
      add_message :error, self.individual_kyc.errors.full_messages
    end
  end

  protected
  def kyc_strong_params
    # params.require(:individual_kyc).permit(:id_proof, :address_proof)
    params = {}
    ## DEPRICATED START ##
    params[:id_proof]= self.params[:individual_kyc][:id_proof] if self.params[:individual_kyc][:id_proof].present?
    params[:address_proof] = self.params[:individual_kyc][:address_proof] if self.params[:individual_kyc][:address_proof].present?
    ## DEPRICATED END ##
    params[:kyc_file_1]= self.params[:individual_kyc][:kyc_file_1] if self.params[:individual_kyc][:kyc_file_1].present?
    params[:kyc_file_2] = self.params[:individual_kyc][:kyc_file_2] if self.params[:individual_kyc][:kyc_file_2].present?
    params[:kyc_number]= self.params[:individual_kyc][:kyc_number] if self.params[:individual_kyc][:kyc_number].present?
    params[:type_id]= self.params[:individual_kyc][:type_id] if self.params[:individual_kyc][:type_id].present?
    params
  end

end