class Company::Show < Company::Base

  attr_accessor :company

  def init
    self.company = Company.find_by(id: params[:id])
  end

  def authorize
    unless Constants::SUPERADMIN_ACCOUNTS.include?(user.email)
      raise_unauthorized_exception
    end
  end

  def success
    Company::Base::CompanyPresenter.new(user, company: company)
  end

end