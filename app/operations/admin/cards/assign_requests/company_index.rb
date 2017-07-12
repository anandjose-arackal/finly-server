class Admin::Cards::AssignRequests::CompanyIndex < Admin::Cards::AssignRequests::Base
  attr_accessor :companies

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    pending_requests_presenter = Admin::Cards::AssignRequests::Index.(user, params)
    unless pending_requests_presenter.success?
      add_message :error, pending_requests_presenter.messages[:error]
    end
    assign_requests = pending_requests_presenter.assign_card_requests
    assign_requests_user_ids = assign_requests.pluck(:card_owner_id)
    assign_requests_users = User.with_id(assign_requests_user_ids)
    assign_requests_companies = Company.with_id(User.with_id(assign_requests_user_ids).pluck(:company_id))

    self.companies = []
    assign_requests_companies.each do |company|
      self.companies << {id: company.id, name: company.name, pending_assign_request_count: assign_requests_users.with_company_id(company.id).count}
    end
  end

  def validate

  end

  def success
    params[:companies] = self.companies
    Admin::Cards::AssignRequests::CompanyIndex::SuccessPresenter.new(user, params, messages)
  end

  class Admin::Cards::AssignRequests::CompanyIndex::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :companies

    def init
      self.companies = params[:companies]
    end
  end

end