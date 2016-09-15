# basic analytics for the admins, managers, and finance_managers
# 4 types of charts : user wise expenses (personal and team), merchant wise expenses, category wise expenses, manager wise expenses
# user wise:


class Analytics::Charts < BaseOperation

  include HasScope

  has_scope :filter_category_id
  has_scope :filter_merchant
  has_scope :filter_receipt
  has_scope :filter_search
  has_scope :filter_amount, using: [:type, :value], type: :hash
  has_scope :filter_status_id
  has_scope :filter_date, using: [:from, :to], type: :hash

  attr_accessor :team_users, :user_ids, :fields, :charts, :expenses

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "No user or params present."
    end
  end

  def init
    self.team_users = User::Team::Index.new(user, params).run
    self.charts = {}
  end

  def authorize
    if user.admin? or user.manager? or user.finance_manager?
      self.fields = [:user, :merchant, :category]
    else
      self.fields = [:merchant, :category]
    end
  end

  def pre_process
    # applying filters for user_id
    self.team_users = team_users.where(id: params[:filter_user_id])
    self.user_ids = team_users.pluck(:id)
    self.expenses = Expense.where(user_id: user_ids)
    # applying the filters for which expenses are to be considered
    apply_filters
  end

  def process
    fields.each do |field|
      generate_charts(field)
    end
    self.response = charts
  end


  private

  def generate_charts(field, options = {})
    case field
      when :user
        charts[:user] = {}
        expense_sums = expenses.joins(:amount).group(:user_id).sum(:value)
        user_ids.each do |id|
          user_name = User.find_by(id: id).name
          charts[:user][user_name] = expense_sums[id]
        end
      when :merchant
        # this already returns a hash with merchant name and total
        set = expenses.select('merchant as merchant_name, SUM(value) as merchant_sum, expenses.*').joins(:manual_expense).joins(:amount).group(:merchant).sum(:value)
        charts[:merchant] = set
      when :category
        charts[:category]
        set = expenses.select('category_id as category, SUM(value) as category_sum, expenses.*').joins(:manual_expense).joins(:amount).group(:category_id).sum(:value)
        set.each do |key, value|
          charts[:category][Category.find(key).name] = value
        end
      else
        # do nothing
    end
  end

  def apply_filters
    self.expenses = apply_scopes(expenses)
  end
end