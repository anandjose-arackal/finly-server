class Admin::KycProcesses::Companies::Update < KycProcess::Company::Update

  attr_accessor :company, :company_kyc, :kyc_params

  def pre_validate
    unless user.finly_admin?
      raise_unauthorized_exception
    end
    if user.blank?
      add_message :error, "Invalid parameters, please try again"
      return
    end
    if params.blank? || params[:company_kyc].blank?
      add_message :error, "Invalid parameters, please try again"
    end
  end

  def init
    id = params[:id] || params[:company_id]
    self.company = Company.find_by(id: id)
    self.company_kyc = company&.company_kyc
    self.kyc_params = kyc_strong_params
  end

end