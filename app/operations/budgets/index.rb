class Budgets::Index < Budgets::Base
  attr_accessor :budgets

  def pre_validate

  end

  def init
    self.budgets = user.company.budgets.roots.contains_date(Date.today)
  end

  def success
    params[:budgets] = budgets.include_details
    Budgets::Index::IndexPresenter.new(user, params, messages)
  end

  class Budgets::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :budgets

    def init
      self.budgets = params[:budgets]
    end
  end
end