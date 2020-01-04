class Dashboard::ExpenseManagement::MoneyRequestsDashboard < Dashboard::ExpenseManagement::Base
  attr_accessor :money_requests

  def init
    # {"view"=>"personal", "menu"=>{"main"=>"reports"}, "page"=>"1", "per_page"=>"30"}
    self.money_requests = MoneyRequests::Index.(user, params)

  end

  def success
    params[:money_requests] = self.money_requests
    Dashboard::ExpenseManagement::MoneyRequestsDashboard::DashboardPresenter.new(user, params, messages)
  end


  class Dashboard::ExpenseManagement::MoneyRequestsDashboard::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :money_requests, :counts

    has_scope :filter_date, using: [:from, :to], type: :hash

    def init
      general_filter_params = {
      }

      self.money_requests = apply_scopes(params[:money_requests], params)
      self.money_requests = self.money_requests.money_requests.includes(:payment_mode, {destination_pocket: :base_currency}, {items: [{money_request: [:payment_mode, {destination_pocket: :base_currency}]}, {amount: [:currency]}]})

      self.counts = []

      personal_money_request_data = {
          type: 'personal_money_request',
          data: [
              {
                  title: "Unsubmitted",
                  count: self.money_requests.filter_status(1, user.id)&.count,
                  total_amount: self.money_requests.filter_status(1, user.id).map {|mr| mr.total_amount}&.compact&.sum,
                  filters: [{filter_status: 1}]
              },

              {
                  title: "Processing",
                  count: self.money_requests.filter_status(2, user.id)&.count,
                  total_amount: self.money_requests.filter_status(2, user.id).map {|mr| mr.total_amount}&.compact&.sum,
                  filters: [{filter_status: 2}]
              },

              {
                  title: "Rejected",
                  count: self.money_requests.filter_status(4, user.id)&.count,
                  total_amount: self.money_requests.filter_status(4, user.id).map {|mr| mr.total_amount}&.compact&.sum,
                  filters: [{filter_status: 4}]
              },

              {
                  title: "Approved",
                  count: self.money_requests.filter_status(5, user.id)&.count,
                  total_amount: self.money_requests.filter_status(5, user.id).map {|mr| mr.total_amount}&.compact&.sum,
                  filters: [{filter_status: 5}]
              }
          ]

      }

      self.counts << personal_money_request_data

    end
  end
end
