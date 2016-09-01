class Expense::Index < Expense::Base
  attr_accessor :role_id, :expenses

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def pre_validate
    if user.blank?
      errors << 'User not found'
    end
  end

  def init
    self.role_id = params[:role_id]
    if self.role_id.blank? and params[:view].present?
      self.role_id = UserRole::VALUES[params[:view].to_sym]
    end
  end

  def authorize
    if self.role_id.present?
      raise_unauthorized_exception unless user.has_role?(self.role_id)
    elsif not user.employee?
      raise_unauthorized_exception
    end
  end

  def process
    case role_id
      when UserRole.admin_id
        user_ids = User::Team::Show.(user, role_id).pluck(:id)
        self.expenses = Expense.where(user_id: user_ids).submitted.includes(:manual_expense)
      when UserRole.finance_manager_id
        user_ids = User::Team::Show.(user, role_id).pluck(:id)
        self.expenses = Expense.where(user_id: user_ids).submitted.includes(:manual_expense)
      when UserRole.manager_id
        user_ids = User::Team::Show.(user, role_id).pluck(:id)
        self.expenses = Expense.where(user_id: user_ids).submitted.includes(:manual_expense)
      when UserRole.auditor_id
      else
        self.expenses = user.expenses.unreported.includes(:manual_expense)
    end
  end

  def retrieve
    if is_success?
      params[:expenses] = self.expenses
      Expense::Index::ExpenseListPresenter.new(user, params)
    else
      false
    end
  end

  class Expense::Index::ExpenseListPresenter < Expense::Base::ExpensePresenter
    include HasScope

    attr_accessor :expenses, :categories

    # scopes for filters
    has_scope :filter_sort, using: [:sort_by, :order], type: :hash
    has_scope :filter_category_id
    has_scope :filter_merchant
    has_scope :filter_receipt
    has_scope :filter_search
    has_scope :filter_amount, using: [:type, :value], type: :hash
    has_scope :filter_status_id
    has_scope :filter_date, using: [:from, :to], type: :hash

    def initialize(user, params)
      self.expenses = params[:expenses]
      self.expenses = apply_scopes(expenses, params) if expenses.present?
      self.categories = user.company.active_categories
    end
  end

end