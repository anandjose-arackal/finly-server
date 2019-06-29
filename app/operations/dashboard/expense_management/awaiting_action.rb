class Dashboard::ExpenseManagement::AwaitingAction < Dashboard::ExpenseManagement::Base
  attr_accessor :result, :document_types, :reports

  has_scope :filter_invoice_type

  def init
    self.document_types = {
      manager_reports: false,
      finance_manager_reports: false,

      manager_money_requests: false,
      finance_manager_money_requests: false,
      
      manager_trips: false,
      finance_manager_trips: false,
      travel_manager_trips: false
    }

    self.document_types[:manager_reports] = true if user.manager?
    self.document_types[:finance_manager_reports] = true if user.finance_manager?
    
    self.document_types[:manager_money_requests] = true if user.manager?
    self.document_types[:finance_manager_money_requests] = true if user.finance_manager?

    self.document_types[:manager_trips] = true if user.manager?
    self.document_types[:finance_manager_trips] = true if user.finance_manager?
    self.document_types[:travel_manager_trips] = true if user.travel_manager?

    self.result = []
  end

  def process
    # reports
    if self.document_types[:manager_reports]
      data = {
        title: "Reports awaiting approval",
        type: 'reports',
        count: Report.reviewer_associated_items(user).not_open.exclude_deleted.awaiting_action_items(user.id).count,
        filters: [{filter_status: 99}],
        awaiting_action: true # FE requires this to handle some logic in UI
      }
      self.result.push data
    end
    if self.document_types[:finance_manager_reports]
      data = {
        title: "Reports awaiting credit",
        type: 'reports',
        count: Report.finance_associated_items(user).not_open.exclude_deleted.awaiting_action_items(user.id).count,
        filters: [{filter_status: 99}],
        awaiting_action: true # FE requires this to handle some logic in UI
      }
      self.result.push data
    end

    # money_requests
    if self.document_types[:manager_money_requests]
      data = {
        title: "Money Requests awaiting approval",
        type: 'money_requests',
        count: MoneyRequest.reviewer_associated_items(user).not_open.exclude_deleted.awaiting_action_items(user.id).count,
        filters: [{filter_status: 99}],
        awaiting_action: true # FE requires this to handle some logic in UI
      }
      self.result.push data
    end
    if self.document_types[:finance_manager_money_requests]
      data = {
        title: "Money Requests awaiting credit",
        type: 'money_requests',
        count: MoneyRequest.finance_associated_items(user).not_open.exclude_deleted.awaiting_action_items(user.id).count,
        filters: [{filter_status: 99}],
        awaiting_action: true # FE requires this to handle some logic in UI
      }
      self.result.push data
    end

    # trips
    if self.document_types[:manager_trips]
      data = {
        title: "Trips awaiting approval",
        type: 'trips',
        count: TravelRequest.reviewer_associated_items(user).or(TravelRequest.reviewer_associated_booking_items(user)).not_open.exclude_deleted.awaiting_action_items(user.id).count,
        filters: [{filter_awaiting_approval: true}],
        awaiting_action: true # FE requires this to handle some logic in UI
      }
      self.result.push data
    end
    if self.document_types[:finance_manager_trips]
      data = {
        title: "Trips awaiting credit",
        type: 'trips',
        count: TravelRequest.finance_associated_items(user).not_open.exclude_deleted.awaiting_action_items(user.id).count,
        filters: [{filter_awaiting_approval: true}],
        awaiting_action: true # FE requires this to handle some logic in UI
      }
      self.result.push data
    end
    if self.document_types[:travel_manager_trips]
      data = {
        title: "Trips pending booking",
        type: 'trips',
        count: TravelRequest.travel_associated_items(user).not_open.exclude_deleted.awaiting_action_items(user.id).count,
        filters: [{filter_awaiting_approval: true}],
        awaiting_action: true # FE requires this to handle some logic in UI
      }
      self.result.push data
    end
  end

  def success
    params[:result] = self.result
    Dashboard::ExpenseManagement::AwaitingAction::DashboardPresenter.new(user, params, messages)
  end


  class Dashboard::ExpenseManagement::AwaitingAction::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :result

    def init
      self.result = params[:result]
    end
  end

end
