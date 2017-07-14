class Admin::KycProcesses::Users::CompanyIndex < Admin::KycProcesses::Users::Base
  attr_accessor :companies

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    individual_kycs_presenter = Admin::KycProcesses::Users::Index.(user, params)
    unless individual_kycs_presenter.success?
      add_message :error, individual_kycs_presenter.messages[:error]
      return
    end
    individual_kycs = individual_kycs_presenter.individual_kycs
    individual_kycs_user_ids = individual_kycs.pluck(:card_owner_id)
    individual_kycs_users = User.with_id(individual_kycs_user_ids)
    individual_kycs_companies = Company.with_id(User.with_id(individual_kycs_user_ids).pluck(:company_id))

    self.companies = []
    individual_kycs_companies.each do |company|
      self.companies << {id: company.id, name: company.name, individual_kyc_count: individual_kycs_users.with_company_id(company.id).count}
    end
  end

  def validate

  end

  def success
    params[:companies] = self.companies
    Admin::KycProcesses::Users::CompanyIndex::SuccessPresenter.new(user, params, messages)
  end

  class Admin::KycProcesses::Users::CompanyIndex::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :companies

    def init
      self.companies = params[:companies]
    end
  end

end