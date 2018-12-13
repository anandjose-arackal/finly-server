class Budgets::Index < Budgets::Base
  attr_accessor :budgets

  def pre_validate

  end

  def pre_process
    if params[:filter_month].blank?
      params[:filter_month] = ""
    end
    if params[:filter_year].blank?
      params[:filter_year] = ""
    end
  end

  def init
    if params[:include_children]
      self.budgets = user.company.budgets.reorder(end_date: :desc)
    else
      self.budgets = user.company.budgets.roots.reorder(end_date: :desc)
    end
  end

  def success
    params[:budgets] = budgets.include_details
    Budgets::Index::IndexPresenter.new(user, params, messages)
  end

  class Budgets::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :budgets, :count, :paginated_budgets

    # has_scope :filter_date, using: [:from, :to], type: :hash
    has_scope :filter_ids
    has_scope :filter_month
    has_scope :filter_year
    has_scope :filter_search

    def init
      self.budgets = params[:budgets]
      self.budgets = apply_scopes(self.budgets, params)
      self.paginated_budgets = self.budgets.paginate(per_page: params[:per_page], page: params[:page])
      self.count = self.budgets.count
    end
  end
end