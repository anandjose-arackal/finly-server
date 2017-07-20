class Admin::KycProcesses::Companies::Confirm < KycProcess::Company::Confirm

  attr_accessor :company, :company_kyc

  def user_model
    AdminUser
  end

  def pre_validate
    unless user.finly_admin?
      raise_unauthorized_exception
    end
    if user.blank? || params[:company_id].blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    id = params[:id] || params[:company_id]
    self.company = Company.find_by(id: id)
    self.company_kyc = company.company_kyc
  end


end