class Admin::Verifier::CompanyIndex < Admin::Cards::AssignRequests::Base
  attr_accessor :companies, :assign_requests_users, :upgrade_request_users

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    # Pending Card Assign Requests
    pending_requests_presenter = Admin::Cards::AssignRequests::Index.(user, params)
    unless pending_requests_presenter.success?
      add_message :error, pending_requests_presenter.messages[:error]
      return
    end
    assign_requests = pending_requests_presenter.card_assign_requests
    assign_requests_user_ids = assign_requests.pluck(:card_owner_id)
    self.assign_requests_users = User.with_id assign_requests_user_ids

    # Pending KYC Upgrades
    individual_kycs_presenter = Admin::KycProcesses::Users::Index.(user, params)
    unless individual_kycs_presenter.success?
      add_message :error, individual_kycs_presenter.messages[:error]
      return
    end
    individual_kycs = individual_kycs_presenter.individual_kycs
    individual_kycs_user_ids = individual_kycs.pluck(:user_id)
    self.upgrade_request_users = User.with_id individual_kycs_user_ids

    # Combined_users
    user_ids = assign_requests_user_ids + individual_kycs_user_ids
    user_ids.uniq!

    pending_comapany_ids = User.with_id(user_ids).pluck(:company_id)
    self.companies = Company.with_id(pending_comapany_ids)
  end

  def validate

  end

  def success
    params[:companies] = self.companies
    params[:assign_requests_users] = self.assign_requests_users
    params[:upgrade_request_users] = self.upgrade_request_users
    Admin::Verifier::CompanyIndex::SuccessPresenter.new(user, params, messages)
  end

  class Admin::Verifier::CompanyIndex::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :companies, :assign_requests_users, :upgrade_request_users

    def init
      self.companies = apply_scopes(params[:companies])&.paginate(page: params[:page], per_page: 30)
      self.assign_requests_users = params[:assign_requests_users]
      self.upgrade_request_users = params[:upgrade_request_users]
    end

    def assign_request_count_for(company)
      assign_requests_users.with_company_id(company.id).count
    end

    def upgrade_request_count_for(company)
      upgrade_request_users.with_company_id(company.id).count
    end

  end

end