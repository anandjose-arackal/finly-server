class Company::Collect::CompanyBranches::Update < Company::Collect::CompanyBranches::Base

  def init
    super
    self.company_branch = self.company_detail.company_branches.find_by id: params[:id]


    self.company_branch_parameters = company_branch_params
  end

  def validate
    unless self.company_branch.present?
      add_message :error, "Cannnot find company branch"
    end
  end

  def process
    self.company_branch.assign_attributes(company_branch_parameters)

    if self.company_branch.valid?
      self.company_branch.save
      add_message :success, "Successfully Updated Company Branch"
    else
      add_message :error, self.company_branch.errors.full_messages
    end
  end

end