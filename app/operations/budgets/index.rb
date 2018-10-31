class Budgets::Index < Budgets::Base
  attr_accessor :budgets

  def pre_validate

  end

  def init
    self.budgets = user.company.budgets.roots.reorder(end_date: :desc)
  end

  def success
    params[:budgets] = budgets.include_details
    Budgets::Index::IndexPresenter.new(user, params, messages)
  end

  class Budgets::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :budgets

    # has_scope :filter_date, using: [:from, :to], type: :hash
    has_scope :filter_ids
    has_scope :filter_month
    has_scope :filter_year
    has_scope :filter_search

    def init
      self.budgets = params[:budgets]
      self.budgets = apply_scopes(self.budgets, params)
    end
  end
end