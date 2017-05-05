class Expense::Index < Expense::Base
  attr_accessor :role_id, :expenses, :expense_filters

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
    self.expense_filters = []
  end

  def authorize
    if self.role_id.present?
      raise_unauthorized_exception if not user.has_role?(self.role_id) and not (role_id == UserRole.id_for(:admin) and user.policy_admin?)
    elsif not user.employee?
      raise_unauthorized_exception
    end
  end

  def pre_process
    # removing all 'filter_*' because we don't want them applied on the user index screen
    params.each do |key, value|
      if key.to_s.include?("filter_")
        expense_filters << {key => value}
        params.delete(key)
      end
    end
  end

  def process
    if role_id.blank? or role_id == UserRole.employee_id
      self.expenses = user.expenses
    elsif params.present? and params[:controller].present? and params[:controller] == 'expenses' and params[:action] == 'index'
      # If viewed from expense index screen
      team_user_ids = User::Index.(user, params).team.map(&:id) rescue nil
      self.expenses = Expense.with_user(team_user_ids).admin_viewable.uniq if team_user_ids.present?
    else
      team_user_ids = User::Index.(user, params).team.map(&:id) rescue nil
      self.expenses = Expense.with_user(team_user_ids).uniq if team_user_ids.present?
    end
    self.expenses = [] if self.expenses.nil?
  end

  def post_process
    # adding the stored filters here before applying scopes
    expense_filters.each do |filter|
      filter.each do |key, value|
        params[key] = value
      end
    end

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
    has_scope :filter_user_id
    has_scope :filter_expense_type_id
    has_scope :filter_amount, using: [:type, :value], type: :hash
    has_scope :filter_status_id
    has_scope :filter_date, using: [:from, :to], type: :hash
    has_scope :filter_expense_cancelled # shows only cancelled expenses
    has_scope :filter_expense_personal # shows only personal expenses

    def init
      self.expenses = params[:expenses]
      if expenses.present?
        self.expenses = apply_scopes(expenses, params)

        ## excluding personal and cancelled expenses if it's an expense/index action
        if params[:action].include?('index')
          exclude_personal
          exclude_cancelled
        end
        ############################################################################

        if params[:view] == 'personal' or params[:view].nil?
          self.paginated_expenses = self.expenses&.unreported_and_rejected.paginate(page: params[:page], per_page: 30)
        else
          self.paginated_expenses = expenses.paginate(page: params[:page], per_page: 30)
        end
      end
      self.categories = user.company.active_categories
    end

    def exclude_cancelled
      if params[:filter_expense_cancelled] == '1'
        self.expenses
      else
        self.expenses = expenses&.non_cancelled
      end
    end

    def exclude_personal
      if params[:filter_expense_personal] == '1'
        self.expenses
      else
        self.expenses = expenses&.non_personal
      end
    end
  end

end
