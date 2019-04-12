class Admin::Expenses::Index < Admin::Expenses::Base

  attr_accessor :expenses

  class Admin::Expenses::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :expenses, :categories, :paginated_expenses

    include HasScope

    has_scope :filter_user
    has_scope :filter_status
    has_scope :filter_type
    has_scope :filter_company
    has_scope :filter_search

    def init
      self.expenses = params[:expenses]
      self.expenses = apply_scopes(expenses, params)
      self.paginated_expenses = expenses.paginate(page: params[:page], per_page: params[:per_page])
      self.categories = user.company.categories.active
    end
  end

  def pre_validate
    super()
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    if params[:show_deleted] == '1'
      self.expenses = Expense.unscoped.all.paginate(page: params[:page])
    else
      self.expenses = Expense.all.paginate(page: params[:page])
    end
  end

  def validate
    unless user.finly_admin?
      add_message :error, "You are not authorized to view this page"
    end
  end

  def process

  end

  def post_process

  end

  def success
    params[:expenses] = expenses
    Admin::Expenses::Index::IndexPresenter.new(user, params, messages)
  end


end