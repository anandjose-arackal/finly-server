class Expense::Index < Expense::Base

  attr_accessor :role_id, :expenses

  class Expense::Index::ExpenseListPresenter < Expense::Base::ExpensePresenter

    attr_accessor :expenses

    def initialize(expenses)
      self.expenses = expenses
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
        user_ids = User::Team::Show.(user, role_id).pluck(:id)
        self.expenses = Expense.where(user_id: user_ids).submitted.includes(:manual_expense)
      when UserRole.finance_manager_id
        user_ids = User::Team::Show.(user, role_id).pluck(:id)
        self.expenses = Expense.where(user_id: user_ids).submitted.includes(:manual_expense)
      when UserRole.manager_id
        user_ids = User::Team::Show.(user, role_id).pluck(:id)
        self.expenses = Expense.where(user_id: user_ids).submitted.includes(:manual_expense)
      when UserRole.employee_id
        self.expenses = user.expenses.unreported.includes(:manual_expense)
    end
  end

  def retrieve
    if is_success?
      list_presenter = Expense::Index::ExpenseListPresenter.new(expenses)
      return list_presenter
    else
      false
    end
  end

end