class Dashboard::ExpenseManagement::Expenses < Dashboard::ExpenseManagement::Base
  attr_accessor :expenses

  def init
    self.expenses = Expense::Index.(user, params)
  end

  def success
    params[:expenses] = self.expenses
    Dashboard::ExpenseManagement::Expenses::DashboardPresenter.new(user, params, messages)
  end


  class Dashboard::ExpenseManagement::Expenses::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :expenses, :counts

    has_scope :filter_date, using: [:from, :to], type: :hash

    def init
      general_filter_params = {
      }

      self.expenses = apply_scopes(params[:expenses], params)
      self.expenses = self.expenses.expenses.includes(:amount).non_personal.unreported_and_rejected

      self.counts = []

      personal_expense_data = {
          type: 'personal_expense',
          data: [
              {
                  title: "Unreported",
                  count: apply_scopes(self.expenses, {filter_status: 2})&.count,
                  total_amount: apply_scopes(self.expenses, {filter_status: 2})&.map {|expense| expense.amount_value}&.compact&.sum,
                  filters: [{filter_status: 2}]
              }
          ]

      }

      self.counts << personal_expense_data

    end
  end
end
