class Company::Collect::CompanyBranches::Show < Company::Collect::CompanyBranches::Base

  def init
    super
    self.company_branch = CompanyBranch.find_by id: params[:id]

  end

  def validate
    unless self.company_branch.present?
      add_message :error, "Cannnot find company branch"
    end
  end

  def process

  end

  def success
    params[:company_branch] = self.company_branch
    Company::Collect::CompanyBranches::Show::ShowPresenter.new(user, params, messages)
  end
  class Company::Collect::CompanyBranches::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :company_branch

    def init
      self.company_branch = params[:company_branch]
    end
  end

end