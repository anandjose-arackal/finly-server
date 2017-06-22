class Expense::Manual::Duplicate::Show < Expense::Base

  def validate
    if self.expense.blank?
      add_message :error, 'Expense not found'
    end
  end

  def success
    Expense::Manual::Duplicate::Show::Presenter.new(user, {expense: self.expense, view: params[:view]}, self.messages)
  end

  class Expense::Manual::Duplicate::Show::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :expense, :duplicate_expenses

    def init
      self.expense = params[:expense]
      self.duplicate_expenses = self.expense&.filtered_duplicate_expenses
    end

  end

end