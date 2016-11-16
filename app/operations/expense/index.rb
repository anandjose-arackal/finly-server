class Expense::Index < Expense::Base
  attr_accessor :role_id, :expenses

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def pre_validate
    if user.blank?
      messages[:error] << 'User not found'
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
    if role_id.blank? or role_id == UserRole.employee_id
      self.expenses = user.expenses.includes(:manual_expense).includes(:card_expense)
    else
      report_ids = Report::Index.(user, params).reports.pluck(:id)
      # adding all card expenses of the users in the team
      team_user_ids = User::Index.(user, params).team.pluck(:id)

      # todo - slightly dirty method - think of a more elegant way to do this
      admin_expense_ids = Expense.with_report(report_ids).pluck(:id)
      admin_expense_ids += Expense.only_card_expenses.with_user(team_user_ids).pluck(:id)
      self.expenses = Expense.where(id: admin_expense_ids).uniq
    end
  end

  def post_process
    if self.expenses.present?
      self.expenses = self.expenses.exclude_deleted rescue self.expenses
    end
  end

  def success
    params[:expenses] = self.expenses
    Expense::Index::ListPresenter.new(user, params, messages)
  end

  class Expense::Index::ListPresenter < Expense::Base::Presenter
    include HasScope

    attr_accessor :expenses, :paginated_expenses, :categories, :unreported_expenses

    # scopes for filters
    has_scope :filter_sort, using: [:sort_by, :order], type: :hash
    has_scope :filter_category_id
    has_scope :filter_merchant
    has_scope :filter_receipt
    has_scope :filter_search
    has_scope :filter_expense_type_id
    has_scope :filter_amount, using: [:type, :value], type: :hash
    has_scope :filter_status_id
    has_scope :filter_date, using: [:from, :to], type: :hash

    def init
      self.expenses = params[:expenses]
      if expenses.present?
        self.expenses = apply_scopes(expenses, params)
        self.unreported_expenses = expenses.unreported
        if params[:view] == 'personal' or params[:view].nil?
          self.paginated_expenses = self.unreported_expenses.paginate(page: params[:page], per_page: 30)
        else
          self.paginated_expenses = expenses.paginate(page: params[:page], per_page: 30)
        end
      end
      self.categories = user.company.active_categories
    end
  end

end