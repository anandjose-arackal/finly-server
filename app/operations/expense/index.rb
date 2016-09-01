class Expense::Index < Expense::Base

  attr_accessor :role_id, :expenses

  class Expense::Index::ExpenseListPresenter < Expense::Base::ExpensePresenter

    include HasScope

    attr_accessor :expenses, :merchants, :count, :categories

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
      self.expenses = apply_scopes(expenses, params[:filter_params]) if expenses.present?
      self.merchants = expenses.manual.pluck(:merchant)
      self.merchants += expenses.card.pluck(:editable_merchant)
      # self.count = expenses.count - for some reason this doesn't work, so getting the count by the size of the association array
      self.count = expenses.size
      self.categories = user.company.active_categories
    end
  end

  def initialize(user, role_id, params={})
    super(user, params)
    self.role_id = role_id
  end

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def self.call(user, role_id, params={})
    self.new(user, role_id, params).run
  end

  def pre_validate
    if user.blank?
      errors << "No user passed"
    end
    if role_id.blank?
      errors << "Role id not present."
    end
  end

  def authorize

  end

  def process
    case role_id
      when UserRole.admin_id
        user_ids = User::Team::Show.(user, role_id).team.pluck(:id)
        self.expenses = Expense.where(user_id: user_ids).submitted.includes(:manual_expense)
      when UserRole.finance_manager_id
        user_ids = User::Team::Show.(user, role_id).team.pluck(:id)
        self.expenses = Expense.where(user_id: user_ids).submitted.includes(:manual_expense)
      when UserRole.manager_id
        user_ids = User::Team::Show.(user, role_id).team.pluck(:id)
        self.expenses = Expense.where(user_id: user_ids).submitted.includes(:manual_expense)
      when UserRole.employee_id
        self.expenses = user.expenses.unreported.includes(:manual_expense)
    end
  end

  def retrieve
    if is_success?
      list_presenter = Expense::Index::ExpenseListPresenter.new(user, {expenses: expenses, filter_params: params})
      return list_presenter
    else
      false
    end
  end

end