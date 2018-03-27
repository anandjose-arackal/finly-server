class Company::Collect::CompanyLogo::Update < Company::Base

  attr_accessor :company_detail

  def init
    self.company_detail = user.company.collect_company_detail
  end

  def validate
    if self.company_detail.blank?
      add_message :error, "Company configuration not found"
      return
    end
  end

  def process
    unless self.company_detail.update(company_details_params)
      add_message :error, self.company_detail.errors.full_messages
    end
  end

  private

  def company_details_params
    params.require(:company).permit(:company_logo)
  end
end