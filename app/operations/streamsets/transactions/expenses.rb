class Streamsets::Transactions::Expenses < BaseOperation
  attr_accessor :expenses

  def pre_validate

  end

  def init
    op = ::Reports::Index.(user, params)
    if op.failure?
      add_message :error, op.messages[:error]
      return
    end

    reports = op.reports
  	self.expenses = Expense.where(report_id: reports.pluck(:id)).include_details

  end

  def success
    params[:expenses] = self.expenses
    Streamsets::Transactions::ExpensesPresenter.new(user, params, messages)
  end

  class Streamsets::Transactions::ExpensesPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :expenses, :paginated_expenses

    def init
      self.expenses = params[:expenses]
      page = params[:page] || 1
      per_page = params[:per_page] || 500
      self.paginated_expenses = self.expenses.order(report_id: :desc).paginate(page: page, per_page: per_page)
    end
  end


end