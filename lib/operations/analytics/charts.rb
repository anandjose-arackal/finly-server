# basic analytics for the admins, managers, and finance_managers
# 4 types of charts : user wise expenses (personal and team), merchant wise expenses, category wise expenses, manager wise expenses
# user wise:


class Analytics::Charts < BaseOperation

  attr_accessor :team_users, :user_ids, :fields, :charts

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "No user or params present."
    end
  end

  def init
    self.team_users = User::Team::Index.new(user, params).run
    self.user_ids = team_users.pluck(:id)
    self.charts = {}
  end

  def authorize
    if user.admin? or user.manager? or user.finance_manager?
      self.fields = [:user, :merchant, :category]
    else
      self.fields = [:merchant, :category]
    end
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
        expense_sums = Expense.where(user_id: user_ids).joins(:amount).group(:user_id).sum(:value)
        user_ids.each do |id|
          user_name = User.find_by(id: id).name
          charts[:user][user_name] = expense_sums[id]
        end
      when :merchant
        # this already returns a hash with merchant name and total
        set = Expense.where(user_id: user_ids).select('merchant as merchant_name, SUM(value) as merchant_sum, expenses.*').joins(:manual_expense).joins(:amount).group(:merchant).sum(:value)
        charts[:merchant] = set
      when :category
        charts[:category]
        set = Expense.where(user_id: user_ids).select('category_id as category, SUM(value) as category_sum, expenses.*').joins(:manual_expense).joins(:amount).group(:category_id).sum(:value)
        set.each do |key, value|
          charts[:category][Category.find(key).name] = value
        end
      else
        # do nothing
    end
  end
end