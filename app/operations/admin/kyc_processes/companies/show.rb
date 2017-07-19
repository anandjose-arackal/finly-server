class Admin::KycProcesses::Companies::Show < KycProcess::Company::Show

  attr_accessor :company, :company_kyc

  def user_model
    AdminUser
  end

  def pre_validate
    unless user.finly_admin?
      raise_unauthorized_exception
    end
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, please try again"
    end
  end

  def init
    id = params[:id] || params[:company_id]
    self.company = Company.find_by(id: id)
    self.company_kyc = company&.company_kyc
  end

  def validate
    if company.blank? || company_kyc.blank?
      add_message :error, "This company is not configured correctly"
    end
  end

  def success
    params[:company_kyc] =  self.company_kyc
    KycProcess::Company::Show::DocumentsPresenter.new(user, params, messages)
  end

end