class KycProcess::Company::Base < BaseOperation
  attr_accessor :company_kyc

  def pre_validate
    if user.blank?
      add_message :error, 'Company not found'
      return
    end
  end

  def init
    self.company = user.company
    self.company_kyc = user.company.company_kyc
  end

  def validate
    if self.company_kyc.blank?
      add_message :error, 'Company not found'
    end
  end

end