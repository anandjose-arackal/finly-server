# basic analytics for the admins, managers, and finance_managers
# 4 types of charts : user wise expenses (personal and team), merchant wise expenses, category wise expenses, manager wise expenses
# user wise:


class Analytics::Charts < BaseOperation

  include HasScope

  class Analytics::Charts::ChartsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :charts

    def init
      self.charts = params[:charts]
    end
  end

  has_scope :filter_category_id
  has_scope :filter_merchant
  has_scope :filter_receipt
  has_scope :filter_search
  has_scope :filter_amount, using: [:type, :value], type: :hash
  has_scope :filter_status_id
  has_scope :filter_date, using: [:from, :to], type: :hash

  attr_accessor :team_users, :user_ids, :field, :charts, :expenses, :role

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "No user or params present."
    end
  end

  def init
    self.role = params[:view]
    self.field = params[:filter_analytics_type]
    if role.nil? or role == 'personal'
      self.team_users = [user]
    else
      self.team_users = User::Team::Index.new(user, params).run
    end
    self.charts = []
  end

  def authorize
    # if user.admin? or user.manager? or user.finance_manager?
    #   self.fields = [:user, :merchant, :category]
    # else
    #   self.fields = [:merchant, :category]
    # end
  end

  def pre_process
    # applying filters for user_id
    self.team_users = team_users.where(id: params[:filter_user_id].to_i) if params[:filter_user_id]
    # extracting the id of the user whose expense breakdown needs to be shown
    if role.nil? or role == 'personal'
      self.user_ids = user.id
      self.expenses = Expense.where(user_id: user_ids)
    else
      self.user_ids = team_users.pluck(:id)
      self.expenses = Expense.admin_viewable.where(user_id: user_ids)
    end
    # applying the filters for which expenses are to be considered
    apply_filters
  end

  def process
    generate_charts(field)
  end

  def success
    Analytics::Charts::ChartsPresenter.new(user, {charts: charts}, messages)
  end


  private

  def generate_charts(field)

    case field
      when 'category'
        set = expenses.select('category_id as category, SUM(value) as category_sum, expenses.*').joins(:manual_expense).joins(:amount).group(:category_id).sum(:value)
        set.each do |key, value|
          cat_name = Category.find(key).name
          charts << {cat_name => value}
        end
      when 'merchant'
        # this already returns a hash with merchant name and total
        self.charts = expenses.select('merchant as merchant_name, SUM(value) as merchant_sum, expenses.*').joins(:manual_expense).joins(:amount).group(:merchant).sum(:value)
      when 'user'
        expense_sums = expenses.joins(:amount).group(:user_id).sum(:value)
        user_ids.each do |id|
          user_name = User.find_by(id: id).name
          charts << {user_name => expense_sums[id]}
        end
      else
        set = expenses.select('category_id as category, SUM(value) as category_sum, expenses.*').joins(:manual_expense).joins(:amount).group(:category_id).sum(:value)
        set.each do |key, value|
          cat_name = Category.find(key).name
          charts << {cat_name => value}
        end
    end
  end

  def apply_filters
    self.expenses = apply_scopes(expenses, params)
  end
end