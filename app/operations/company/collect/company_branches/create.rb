class Company::Collect::CompanyBranches::Create < Company::Collect::CompanyBranches::Base


  def init
    super
    self.company_branch_parameters = company_branch_params
  end

  def process
    debugger
    self.company_branch = self.company_detail.company_branches.build(company_branch_parameters)

    if self.company_branch.save
      add_message :success, "Successfully Added Company Branch"
    else
      add_message :error, self.company_branch.errors.full_messages
    end
  end

end