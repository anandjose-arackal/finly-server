class Company::Create < Company::Base

  attr_accessor :company, :admin

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << 'No user or params passed'
    end
  end

  def init

  end

  def authorize
    unless Constants::SUPERADMIN_ACCOUNTS.include?(user.email)
      raise_unauthorized_exception
    end
  end

  def validate

  end

  def process
    self.company = Company.new(company_params)
    unless company.save
      add_message :error, company.errors.full_messages
      return
    end
  end

  def post_process
    company&.company_kyc&.update(company_type_id: 3)
    add_message :success, "Company created successfully!"
  end

  def success
    Company::Base::CompanyPresenter.new(user, company: company)
  end

  private

  def company_params
    params.require(:company).permit(:name, itz_cash_property_attributes: [:d_code])
  end

end