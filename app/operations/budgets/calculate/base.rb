class Budgets::Calculate::Base < BaseOperation
  attr_accessor :budget, :spent_amount

  def init
    self.budget = params[:budget]
    self.spent_amount = 0
  end

  def process
  end

  def success
    params[:budget] = self.budget
    params[:spent_amount] = self.spent_amount
    Budgets::Calculate::Base::BasePresenter.new(user, params, messages)
  end

  class Budgets::Calculate::Base::BasePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :result, :budget

    def init
      self.budget = params[:budget]
      self.result = {
        budget: self.budget,
        budget_amount: self.budget.budget_amount.value,
        spent_amount: params[:spent_amount],
        associated_item: get_associated_item
      }
    end

    def get_associated_item
      item = budget.budgetable_type.constantize.with_id(self.budget.budgetable_id).first

      item_details = {
        type: self.budget.budgetable_type,
        id: item.id,
        name: item.name
      }
    end
  end
end