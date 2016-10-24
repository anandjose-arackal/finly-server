class AnalyticsService < BaseService

  attr_accessor :charts

  def initialize(current_user)
    super()
    self.charts = {}
    @user = current_user
    @UTService = UserTeamService.new(@user)
  end


  def generate_charts(options={}, params)
    admin = false
    if params[:view] == 'admin'
      admin = true
    end
    charts = {}
    if @user.admin?
      # generates charts for admin - includes user wise and manager wise breakdown of expenses
      manager_chart = chart(:manager_id, options, admin)
      charts[:manager] = manager_chart
    end
    user_chart = chart(:user_id, options, admin)
    charts[:user] = user_chart
    category_chart = chart(:category_id, options, admin)
    charts[:category] = category_chart
    merchant_chart = chart(:merchant, options, admin)
    charts[:merchant] = merchant_chart
    charts
  end

  private

  def chart(with, options={}, admin)

    # construct the filters based on options

    # extract the ids of the users that will be part of the charts - only self in case of non admins ; all users in case of admins
    if admin
      user_ids = @user.company.get_active_users.pluck(:id)
    else
      user_ids = @user.id
    end
    expenses = Expense.where(user_id: user_ids)

    # extracting merchant wise breakdown of expenses
    case with
      when :merchant
        set = expenses.select('merchant as merchant_name, SUM(value) as merchant_sum, expenses.*').joins(:manual_expense).joins(:amount).group(:merchant)
        set.each do |exp|
          charts[:merchant] = {name: exp.merchant_name, amount: exp.merchant_sum}
        end
      when :category_id
        set = expenses.select('name as category_name, SUM(value) as amount_sum, expenses.*').joins(:category).joins(:amount).group(:category_id)
        set.each do |exp|
          charts[:category] = {name: exp.category_name, amount: exp.amount_sum}
        end
      # when :manager_id
      #
      when :user_id
        set = expenses.select('name as user_name, SUM(value) as user_sum, expenses.*').joins(:amount).joins(:user)
        set.each do |exp|
          charts[:user] = {name: exp.user_name, amount: exp.amount}
        end
      else
        # do nothing
    end

    # query = "users.company_id = #{company_id}"
    # amount_query=""
    # manager_id = nil
    # user_id = nil
    # if manager?
    #   manager_id = self.all_users(company).where(user_type_id: 3).all.pluck(:id)
    # end
    # if employee?
    #   user_id = id
    # end
    # unless options.blank?
    #   options.each do |key, value|
    #     case key
    #       when 'filter_search'
    #         next if value.blank?
    #         query+= ") AND (users.name like \"%#{value}%\" OR users.email like \"%#{value}%\" OR expenses.merchant like \"%#{value}%\""
    #       when 'filter_merchant'
    #         next if value.blank?
    #         query += " AND expenses.merchant like \"#{value}\""
    #       when 'filter_category_id'
    #         next if value.blank?
    #         query += " AND expenses.category_id = #{value}"
    #       when 'filter_status'
    #         next if value.blank?
    #         query += " AND expenses.status = #{value}"
    #       when 'filter_date'
    #         next unless value.is_a?(Hash) || value[:type].blank? || (value[:from].blank? && value[:to].blank?)
    #         type = value[:type]
    #         from = value[:from] || DateUtils.local_date
    #         to = value[:to]
    #         type_val = nil
    #         if type == 'expense'
    #           type_val = 'expenses.date'
    #         elsif type == 'submitted'
    #           type_val = 'expenses.created_at'
    #         end
    #         query += " AND #{type_val} >= '#{from}'" if from && type_val
    #         query += " AND #{type_val} <= '#{to}'" if to && type_val
    #       when 'filter_amount'
    #         next unless value.is_a?(Hash)|| value[:type].blank? || value[:value].blank?
    #         type = value[:type]
    #         type_val = nil
    #         amount = value[:value]
    #         if type == 'lt' || type == 'lteq'
    #           type_val = '<='
    #         elsif type == 'eq'
    #           type_val = '='
    #         elsif type =='gteq' || type == 'gt'
    #           type_val = '>='
    #         end
    #         amount_query += "expenses.amount #{type_val} #{amount}" if type_val
    #       when 'filter_user_id', 'user_id'
    #         user_id = value unless self.all_users(company).find_by(id: value).blank?
    #       when 'filter_manager_id', 'manager_id'
    #         manager_id = value unless self.all_users(company).find_by(id: value).blank?
    #     end
    #   end
    # end
    # unless manager_id.blank?
    #   manager_ids_string = manager_id.to_s.gsub("[", "").gsub("]", "")
    #   query += " AND users.manager_id IN (#{manager_ids_string})"
    #   # todo this code is to include manager in his team as well during search
    #   # if with == :manager_id
    #   #   query += " AND users.manager_id IN (#{manager_ids_string})"
    #   # else
    #   # query += " AND users.id IN (#{manager_ids_string}) OR users.manager_id IN (#{manager_ids_string})"
    #   # end
    # end
    # query += " AND users.id = #{user_id}" unless user_id.blank?
    #
    # # actual selection and creation of the respective charts
    # case with
    #   when :user_id
    #     User.select('users.id, users.name as name, SUM(expenses.amount) as amount').joins(:expenses).group(:id).order('SUM(amount) DESC').merge(Expense.where(amount_query).where(query)).map(&:attributes)
    #   when :manager_id
    #     # Much more code as manager_id to manager name mapping has to be done on the same table
    #     users = User.joins(:expenses).where(query).group(with).order('SUM(amount) DESC').merge(Expense.where(amount_query).where(query)).sum(:amount)
    #     ids = User.deep_hash_keys(users)
    #     ids.delete(nil)
    #     user_id_name_map = Hash[User.where(id: ids).all.map { |c| [c.id, c.name] }]
    #     result = []
    #     users.each do |key, value|
    #       name = "No manager"
    #       unless key.blank?
    #         name = user_id_name_map[key]
    #       end
    #       result << {'id' => key, 'name' => name, 'amount' => value}
    #     end
    #     return result
    #   when :category_id
    #     Expense.unscoped.select('categories.id, categories.name as name, SUM(expenses.amount) as amount').joins(:category, :user).where(query).group("categories.id, categories.name").order('SUM(expenses.amount) DESC').merge(Expense.where(amount_query).where(query)).map(&:attributes)
    #   when :merchant
    #     User.select('merchant as name, SUM(amount) as amount').joins(:expenses).where(query).group(:merchant).order('SUM(amount) DESC').merge(Expense.where(amount_query).where(query)).map(&:attributes)
    # end
  end


  def deep_hash_keys(h)
    h.keys + h.map { |_, v| v.is_a?(Hash) ? deep_hash_keys(v) : nil }.flatten.compact
  end
end

