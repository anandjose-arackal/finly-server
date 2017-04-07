class Superadmin::Company::Update < Superadmin::Base

  attr_accessor :company, :company_update_params

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << 'No user or params passed'
    end
  end

  def init
    self.company = Company.find_by(id: params[:id])
    self.company_update_params = company_params
  end

  def authorize
    unless Constants::SUPERADMIN_ACCOUNTS.include?(user.email)
      raise_unauthorized_exception
    end
  end

  def validate

  end

  def pre_process
    company_update_params[:itz_cash_property_attributes][:id] = company.itz_cash_property.id
  end

  def process
    unless company.update(company_update_params)
      add_message :error, company.errors.full_messages
      return
    end
  end

  def post_process
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
