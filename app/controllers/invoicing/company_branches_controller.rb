class Invoicing::CompanyBranchesController < BaseControllers::PublicBase
  def show
    @result = Company::Collect::CompanyBranches::Show.(current_user, params)
    respond
  end

  def create
    @result = Company::Collect::CompanyBranches::Create.(current_user, params)
    respond
  end

  def update
    @result = Company::Collect::CompanyBranches::Update.(current_user, params)
    respond
  end
end
