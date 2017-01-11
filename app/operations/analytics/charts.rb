# basic analytics for the admins, managers, and finance_managers
# 4 types of charts : user wise expenses (only for managers), merchant wise expenses, category wise expenses



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
  has_scope :filter_expense_type_id

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

  end

  def pre_process
    # applying filters for user_id
    self.team_users = team_users.signed_up.where(id: params[:filter_user_id].to_i) if params[:filter_user_id].present?
    # extracting the id of the user whose expense breakdown needs to be shown
    if role.nil? or role == 'personal'
      self.user_ids = user.id
      self.expenses = Expense.where(user_id: user_ids)
    else
      self.user_ids = team_users.signed_up.pluck(:id)
      self.expenses = Expense.where(user_id: user_ids)
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

    total = 0
    case field
      when 'category'
        set = expenses.select('category_id as category, SUM(value) as category_sum, expenses.*').joins(:amount).group(:category_id).sum(:value)
        set.each do |key, value|
          category = Category.find(key)
          cat_name = category.name
          charts << {item: cat_name, item_total: precision_value(value), details: status_wise_distribution(category)}
          total += precision_value(value)
        end
        charts << {meta: true, total: total}
      when 'merchant'

        # todo - need to rethink

        self.expenses = expenses.paginate(page: params[:page])
        # this already returns a hash with merchant name and total - and the expense types are already filtered
        manual_items = expenses.select('merchant as merchant_name, SUM(value) as merchant_sum, expenses.*').joins(:manual_expense).joins(:amount).group(:merchant).sum(:value)
        card_items = expenses.select('editable_merchant as merchant_name, SUM(value) as merchant_sum, expenses.*').joins(:card_expense).joins(:amount).group(:editable_merchant).sum(:value)
        manual_items.each do |key, value|
          self.charts << {item: key, item_total: precision_value(value), details: status_wise_distribution(key)}
          total += precision_value(value)
        end
        card_items.each do |key, value|
          self.charts << {item: key, item_total: precision_value(value), details: status_wise_distribution(key)}
          total += precision_value(value)
        end
        charts << {meta: true, total: total}
      when 'user'
        expense_sums = expenses.joins(:amount).group(:user_id).sum(:value)
        user_ids.each do |id|
          user = User.find_by(id: id)
          user_name = user.name
          expense_sum = expense_sums[id] ? precision_value(expense_sums[id]) : 0
          charts << {item: user_name, item_total: expense_sum, details: status_wise_distribution(user)}
          total += expense_sum
        end
        charts << {meta: true, total: total}
      else
        # default will be category wise breakdown
        set = expenses.select('category_id as category, SUM(value) as category_sum, expenses.*').joins(:amount).group(:category_id).sum(:value)
        set.each do |key, value|
          cat_name = Category.find(key).name
          charts << {item: cat_name, item_total: precision_value(value)}
          total += precision_value(value)
        end
        charts << {meta: true, item_total: total}
    end
    # sorting the charts in descending order of total
    charts.sort_by! { |item| item[:item_total] || item[:total]}
    charts.reverse!
  end

  def apply_filters
    self.expenses = apply_scopes(expenses, params)
  end

  def status_wise_distribution(type)
    result_hash = {}
    if type.is_a?(Category)
      exp = expenses.where(category_id: type.id)
    elsif type.is_a?(User)
      exp = expenses.where(user_id: type.id)
    elsif type.is_a?(String)
      exp_ids = []
      expenses.each do |e|
        if e.merchant_name == type
          exp_ids << e.id
        end
      end
      exp = Expense.where(id: exp_ids)
    else
      exp = []
    end

    if params[:filter_expense_status_id]
      params[:filter_expense_status_id].each do |status_id|
        case status_id
          when '1'
            # i.e. all unreported expenses
            exp = exp.where(expense_status_id: [ExpenseStatus.unreported_id, ExpenseStatus.rejected_id, ExpenseStatus.unsubmitted_id])
            result_hash['unreported_expenses'] = exp.joins(:amount).sum(:value)
          when '2'
            r = Report.processing.all
            exp = exp.where(report_id: r)
            result_hash['processing_expenses'] = exp.joins(:amount).sum(:value)
          when '3'
            r = Report.approved.all
            exp = exp.where(report_id: r)
            result_hash['approved_expenses'] = exp.joins(:amount).sum(:value)
          when '4'
            r = Report.processed.all
            exp = exp.where(report_id: r)
            result_hash['reimbursed_expenses'] = exp.joins(:amount).sum(:value)
          else
            # do nothing
        end
      end
    end
    return result_hash
  end

end