class Admin::KycProcesses::Companies::Base < KycProcess::Company::Base
  attr_accessor :company_kyc

  def user_model
    AdminUser
  end

  def pre_validate
    if user.blank? or (params&.dig(:id).blank? and params&.dig(:company_id).blank?)
      add_message :error, 'Company not found'
      return
    end
  end

  def init
    self.company = Company.find_by(id: (params[:id] or params[:company_id]))
    self.company_kyc = user.company.company_kyc if company.present?
  end

  def validate
    if self.company_kyc.blank?
      add_message :error, 'Company not found'
    end
  end

end