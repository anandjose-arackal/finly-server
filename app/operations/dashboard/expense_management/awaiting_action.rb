class Dashboard::ExpenseManagement::AwaitingAction < Dashboard::ExpenseManagement::Base
  attr_accessor :result, :document_types, :reports, :money_requests

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
    params[:view] = get_relevant_view
    self.document_types[:manager_reports] = true if user.manager?
    self.document_types[:finance_manager_reports] = true if user.finance_manager?

    self.document_types[:manager_money_requests] = true if user.manager?
    self.document_types[:finance_manager_money_requests] = true if user.finance_manager?

    self.document_types[:manager_trips] = true if user.manager?
    self.document_types[:finance_manager_trips] = true if user.finance_manager?
    self.document_types[:travel_manager_trips] = true if user.travel_manager?

    self.result = []

    reports_presenter = ::Reports::Index.(user, params)
    unless reports_presenter.success?
      add_message :error, reports_presenter.messages[:error]
      return
    end
    self.reports = reports_presenter.reports.approved.without_associated_processor

    money_requests_presenter = Object.const_get('::MoneyRequests::Index').(user, params)
    unless money_requests_presenter.success?
      add_message :error, money_requests_presenter.messages[:error]
      return
    end
    self.money_requests = money_requests_presenter.money_requests.approved.without_associated_processor
  end

  def process
    # reports
    if self.document_types[:manager_reports]
      data = {
          title: "Reports awaiting approval",
          type: 'reports',
          count: Report.reviewer_associated_items(user).not_open.exclude_deleted.awaiting_action_items(user.id).count,
          filters: [{view: 'manager', filter_status: 99}],
          awaiting_action: true # FE requires this to handle some logic in UI
      }
      self.result.push data
    end
    if self.document_types[:finance_manager_reports]
      data = {
          title: "Reports awaiting credit",
          type: 'settle_reports',
          # count: Report.finance_associated_items(user).not_open.exclude_deleted.awaiting_action_items(user.id).count,
          count: self.reports.count,
          filters: [{view: 'finance', menu: {main: "settlements_dashboard"}}],
          awaiting_action: true # FE requires this to handle some logic in UI
      }
      self.result.push data
    end

    # money_requests
    if self.document_types[:manager_money_requests]
      data = {
          title: "Money Requests awaiting approval",
          type: 'requests',
          count: MoneyRequest.reviewer_associated_items(user).not_open.exclude_deleted.awaiting_action_items(user.id).count,
          filters: [{view: 'manager', filter_status: 99}],
          awaiting_action: true # FE requires this to handle some logic in UI
      }
      self.result.push data
    end
    if self.document_types[:finance_manager_money_requests]
      data = {
          title: "Money Requests awaiting credit",
          type: 'settle_money_requests',
          # count: MoneyRequest.finance_associated_items(user).not_open.exclude_deleted.awaiting_action_items(user.id).count,
          count: self.money_requests.count,
          filters: [{view: 'finance', menu: {main: "settlements_dashboard"}}],
          awaiting_action: true # FE requires this to handle some logic in UI
      }
      self.result.push data
    end

    # trips
    if self.document_types[:manager_trips]
      data = {
          title: "Trips awaiting approval",
          type: 'travel_requests',
          count: TravelRequest.reviewer_associated_items(user).or(TravelRequest.reviewer_associated_booking_items(user)).not_open.exclude_deleted.awaiting_action_items(user.id).count,
          filters: [{view: 'manager', filter_status: 'processing'}],
          awaiting_action: true # FE requires this to handle some logic in UI
      }
      self.result.push data
    end
    if self.document_types[:finance_manager_trips]
      data = {
          title: "Trips awaiting credit",
          type: 'trips',
          count: TravelRequest.finance_associated_items(user).not_open.exclude_deleted.awaiting_action_items(user.id).count,
          filters: [{view: 'finance_manager', filter_status: 'booking_confirmed'}],
          awaiting_action: true # FE requires this to handle some logic in UI
      }
      self.result.push data
    end
    if self.document_types[:travel_manager_trips]
      data = {
          title: "Trips pending booking",
          type: 'trips',
          count: TravelRequest.travel_associated_items(user).not_open.exclude_deleted.awaiting_action_items(user.id).count,
          filters: [{view: 'travel_manager', filter_status: 'booking_pending'}],
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
