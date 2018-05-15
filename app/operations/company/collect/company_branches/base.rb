class Company::Collect::CompanyBranches::Base < Company::Base
  attr_accessor :company_branch, :company_branch_parameters, :company_detail

  def init
    self.company_detail = user.company.collect_company_detail
  end

  def company_branch_params
    params.require(:company_branch).permit(:id, :name, :gst, :pan, :address)
  end
end