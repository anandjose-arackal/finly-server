class Dashboard::ExpenseManagement::Configs < Dashboard::ExpenseManagement::Base
  attr_accessor :departments, :sub_departments, :request_types, :policies, :locations

  def init
    self.departments = Company::Departments::Index.(user, params).policy_department_filter_mapping
    self.policies = user.policies.with_application(current_app).non_default.non_deleted
    self.locations = Company::Locations::Index.(user, params).policy_location_filter_mapping
    self.request_types = {
        awaiting_action: false,
        reports: false,
        money_requests: false,
        trips: false
    }
    subscription = user.company.feature_subscription

    self.request_types[:reports] = subscription.expense_management_enabled
    self.request_types[:money_requests] = subscription.expense_management_enabled
    self.request_types[:trips] = subscription.travel_request

    if user.manager? or user.finance_manager?
      self.request_types[:awaiting_action] = true
    end

  end

  def success
    params[:departments] = self.departments
    params[:request_types] = self.request_types
    params[:policies] = self.policies
    params[:locations] = self.locations
    Dashboard::ExpenseManagement::Configs::DashboardPresenter.new(user, params, messages)
  end

  class Dashboard::ExpenseManagement::Configs::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :departments, :sub_departments, :request_types, :policies, :locations

    has_scope :filter_status_id
    has_scope :filter_user_id
    has_scope :filter_only_roots

    def init
      self.departments = apply_scopes(params[:departments], {filter_only_roots: true})
      self.sub_departments = params[:departments].only_sub_departments rescue Department.none
      self.policies = params[:policies]
      self.locations = params[:locations]
      self.request_types = params[:request_types]
    end
  end

end
