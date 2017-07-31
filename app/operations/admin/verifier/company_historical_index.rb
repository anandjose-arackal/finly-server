class Admin::Verifier::CompanyHistoricalIndex < Admin::Cards::AssignRequests::Base
  attr_accessor :companies, :assign_requests_users, :upgrade_request_users

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    # Pending Card Assign Requests
    pending_requests_presenter = Admin::Cards::AssignRequests::HistoricalIndex.(user, params)
    assign_requests_user_ids = []
    individual_kycs_user_ids = []
    if pending_requests_presenter.success?
      assign_requests = pending_requests_presenter.card_assign_requests
      assign_requests_user_ids = assign_requests&.pluck(:card_owner_id)
      self.assign_requests_users = User.with_id assign_requests_user_ids
    end

    # Pending KYC Upgrades
    individual_kycs_presenter = Admin::KycProcesses::Users::HistoricalIndex.(user, params)
    if individual_kycs_presenter.success?
        # add_message :error, individual_kycs_presenter.messages[:error]
        # return
      individual_kycs = individual_kycs_presenter.individual_kycs
      individual_kycs_user_ids = individual_kycs&.pluck(:user_id)
      self.upgrade_request_users = User.with_id individual_kycs_user_ids
    end

    # Combined_users
    user_ids = []
    if assign_requests_user_ids.present?
      user_ids << assign_requests_user_ids
    end
    if individual_kycs_user_ids.present?
      user_ids << individual_kycs_user_ids
    end
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
    Admin::Verifier::CompanyHistoricalIndex::SuccessPresenter.new(user, params, messages)
  end

  class Admin::Verifier::CompanyHistoricalIndex::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :companies, :assign_requests_users, :upgrade_request_users

    def init
      self.companies = apply_scopes(params[:companies])&.paginate(page: params[:page], per_page: 30)
      self.assign_requests_users = params[:assign_requests_users]
      self.upgrade_request_users = params[:upgrade_request_users]
    end

    def assign_request_count_for(company)
      (assign_requests_users&.with_company_id(company.id)&.count or 0)
    end

    def upgrade_request_count_for(company)
      (upgrade_request_users&.with_company_id(company.id)&.count or 0)
    end

  end

end