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

    def init
      general_filter_params = {
      }

      self.expenses = params[:expenses].expenses.includes(:amount).non_personal.unreported_and_rejected

      self.counts = []

      personal_expense_data = {
        type: 'personal_expense',
        data: [
          {
            title: "Unreported Expenses",
            count: apply_scopes(self.expenses, {filter_status: 2})&.count,
            total_amount: apply_scopes(self.expenses, {filter_status: 2})&.map {|expense| expense.amount_value}&.compact&.sum,
            filters: []
          }
        ]

      }

      self.counts << personal_expense_data

    end
  end
end
