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
    attr_accessor :budget, :spent_amount

    def init
      self.budget = params[:budget]
      self.spent_amount = params[:spent_amount]
    end
  end
end