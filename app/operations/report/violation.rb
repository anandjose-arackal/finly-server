# action to retrieve the violations that are present in a report.
# params:
# report_id: id of the report that requires violations
# return a hash with each expense_id as key, and the value as a hash of the expense and budget violations
# format:
# warning_messages: { expense_id : {expense_warning: {receipt: *contains receipt warning*
#                                                     note: *contains note warning*
#                                                     disallow: *contains disallow warning*}
#                                   expense_blocking: {receipt: *contains receipt blocks*
#                                                     note: *contains note blocks*
#                                                     disallow: *contains disallow blocks*}
#                                   budget_warning: {*category name* : *category budget exceeded warning*
#                                                           ...
#                                                    total: *total budget exceeded warning*
#                                   budget_blocking: {*category name* : *category budget exceeded blocks*
#                                                           ...
#                                                    total: *total budget exceeded blocks* }
#                                   }
#
#                      ... (similarly for all expenses in the report)
#
#                   }

class Report::Violation < Report::Base
  include ActionView::Helpers::NumberHelper
  attr_accessor :no_policy, :warning_messages, :policy, :base_currency_code, :base_currency_id

  def personalizer
    {
        post_process: {
            before: Personalizer::Process.new([:report, :violation], :post_process, self)
        }
    }
  end

  def authorized_user_types
    nil
  end

  def pre_validate
    if params.blank? or params[:report].blank?
      add_message :error, 'Report not found'
    end
  end

  def init
    self.warning_messages = {}
    self.report = params[:report]
    self.policy = report.versioned_policy
    self.base_currency_code = policy.nil? ? (user.company.base_currency.country_code) : (policy.base_currency.country_code)
    self.base_currency_id = policy.nil? ? (user.company.base_currency.id) : (policy.base_currency.id)
    report.expenses.each do |expense|
      self.warning_messages[expense.id] = {}
      self.warning_messages[expense.id]['expense_warning'] = []
      self.warning_messages[expense.id]['expense_blocking'] = []
      self.warning_messages[expense.id]['budget_warning'] = []
      self.warning_messages[expense.id]['budget_blocking'] = []
    end
  end

  def validate
    if self.report.blank? or not self.report.is_a?(Report)
      messages[:error] << 'Report not found'
    end
    unless policy
      self.no_policy = true
    end
  end

  def process

    expense_rules = policy.expense_rules.non_deleted
    budget_rules = policy.budget_rules.non_deleted

    selected_drop_down_items = nil

    # For performance optimization, filtering down budget rules based on selected report custom fields
    if report.custom_fields.only_drop_downs.present?
      value_ids = report.custom_fields.only_drop_downs.pluck(:value_id)
      selected_drop_down_items = FieldDropDownSelection.with_id(value_ids).pluck(:value_id)

      rule_field_mappings = BudgetRuleFieldMapping.where(budget_rule_id: budget_rules.pluck(:id))
      rule_ids = budget_rules.pluck(:id)
      budgets_without_field_mappings = rule_ids - rule_field_mappings.pluck(:budget_rule_id)
      rules_with_relevant_mappings =  rule_field_mappings.where(field_drop_down_item_id: selected_drop_down_items).pluck(:budget_rule_id)
      budget_rules = budget_rules.with_id((budgets_without_field_mappings + rules_with_relevant_mappings))
      # relevant_budget_rule_id = budget_rules
    end

    report.expenses.each do |expense|
      # because the incompatible expense violation needs to be calculated irrespective of the
      # existence of a policy
      check_compatible_expenses(expense)
      check_non_base_currency(expense)
      check_custom_fields(expense)
      check_distance_expense(expense)

      check_cash_on_hand_blocked(expense)
      # i.e. if the expense does not have a possible currency computation skip rule checking because the amount isn't clear
      if expense.amount&.currency_id != base_currency_id && expense.date == DateUtils.local_date
        next
      end

      unless no_policy
        expense_rules.each do |rule|
          check_expense_rule rule, expense
        end
        budget_rules.each do |rule|
          # next if rule.field_drop_down_items.present? and selected_drop_down_items.nil?
          # next unless (selected_drop_down_items - rule.field_drop_down_items.pluck(:id)).size < selected_drop_down_items.size
          check_budget rule, expense
        end
      end

    end
    self.response = warning_messages
  end

  def success
    self.response
  end

  private

  def check_expense_rule_violation(expense, rule, manager = nil)
    message = ''
    if rule.greater_than_amount_value && rule.greater_than_amount_value != 0
      expense_amount = expense.amount.send(base_currency_code.to_sym)
      if expense_amount and expense_amount >= rule.greater_than_amount_value
        message += ' above ' + rule.greater_than_amount_value.to_s
      else
        return false
      end
    end
    if rule.category_id
      if expense.category_id == rule.category_id
        message += ' and belonging to category ' + expense.category_name
      else
        return false
      end
    end

    if rule.days_after
      if manager
        time_elapsed = (expense.report.submitted_at - expense.date).to_i
      else
        time_elapsed = (DateUtils.local_date - expense.date).to_i
      end
      if time_elapsed > rule.days_after
        message += ' added after ' + rule.days_after.to_s + ' days'
      else
        return false
      end
    end

    message
  end

  # checks the passed expense against the passed rule
  def check_expense_rule(rule, expense, manager = nil)
    warning = 'Expenses'
    broken = false
    # first check if there's a violation with the common criteria
    message = check_expense_rule_violation(expense, rule, manager)
    # checking if the specific rule is actually broken
    case rule.expense_rule_type_id
    when 1
      if expense.receipts_count > 0
        message = false # i.e. the rule is not broken because there is a receipt
      end
    when 2
      if expense.note && !expense.note.blank?
        message = false # i.e. the rule is not broken because there is a note
      end
    when 4 #Receipt hard copy required
      hard_copy = true
      expense.receipts.each do |r|
        unless r.hard_copy_received
          hard_copy = false
        end
      end

      if hard_copy
        message = false
      end
    else
      # do nothing
    end
    if message
      warning += message
      broken = true
    end
    warning += ' require a receipt' if rule.expense_rule_type_id == 1
    warning += ' require a note' if rule.expense_rule_type_id == 2
    warning += ' require receipt hard copy submission' if rule.expense_rule_type_id == 4
    warning += ' are not allowed' if rule.expense_rule_type_id == 3
    rule_name = nil
    # initializing the rule name
    case rule.expense_rule_type_id
    when 1
      rule_name = 'receipt'
    when 2
      rule_name = 'note'
    when 3
      rule_name = 'disallow'
    when 4
      rule_name = 'receipt_hard_copy'
    else
      # do nothing
    end

    if broken
      if rule.type == 'Warning'
        self.warning_messages[expense.id]['expense_warning'] << {type: rule_name, message: warning}
      elsif rule.type == 'Blocking'
        self.warning_messages[expense.id]['expense_blocking'] << {type: rule_name, message: warning}
      end
    end
  end

  def available_budget(expense, rule, start_date, end_date, categories, field_drop_down_item_ids)
    user = expense.user
    report = expense.report
    total_expenses = 0
    # all user reports with the associated budget
    report_ids = user.reports.processing_and_above.with_policy_id(rule.policy_id).pluck(:id) + [report.id]

    # Identify reports with the selected custom fields
    if field_drop_down_item_ids.present?
      reports = Report.with_id(report_ids).filter_custom_drop_down_selection(field_drop_down_item_ids)
      report_ids = reports.pluck(:id)
    end

    expenses = Expense.with_report_id(report_ids)

    expense_arrays  = []
    expense_types = rule.expense_types.pluck(:id)
    expense_arrays << ExpenseType.id_for(:manual) if expense_types.include?(1)
    expense_arrays << ExpenseType.id_for(:card) if expense_types.include?(2)
    expense_arrays << ExpenseType.id_for(:distance) if expense_types.include?(3)
    expense_arrays << ExpenseType.id_for(:time) if expense_types.include?(4)
    expense_arrays << ExpenseType.id_for(:per_diem) if expense_types.include?(5)

    expenses = expenses.selected_expense_types(expense_arrays)


    # Expenses with different usage_date ranges from expense date
    total_expenses += number_with_precision(expenses.without_usage_date_type.with_date_range(start_date, end_date)
                                                .filter_category_id(categories&.pluck(:id)).joins(:amount).sum(base_currency_code.to_sym), :precision => 2).to_f

    # Expenses without different usage_date ranges from expense date
    expenses.with_usage_date_type.usage_date_within(start_date, end_date).each do |exp|
      if exp.usage_date_end.blank?
        # If only a single date is defined in usage_date range, add the cost to current budget
        total_expenses += exp.amount.send(base_currency_code.to_sym)
      else
        # If the usage date is partially/completely overlapping with budget date, then (add number of overlapping days with budget)*(cost per date)
        usage_days = exp.usage_days
        next if usage_days.nil?
        total_number_of_days = usage_days.count
        number_of_overlapping_days = ([end_date, usage_days.last].min.to_date - [start_date, usage_days.first].max.to_date).to_i + 1
        cost_per_date = exp.amount.send(base_currency_code.to_sym) / total_number_of_days
        total_expenses += cost_per_date * number_of_overlapping_days
      end
    end

    # if total_expenses > rule.amount.value
    #   return true
    # end
    # false

    if rule.amount.present?
      # Rule is independent of receipt
      return (rule.amount.value - total_expenses), :total
    else
      # Rule contains condition of with and without receipt
      all_receipts_avaialble = (Receipt.with_expense_id(expenses.pluck(:id)).pluck(:parent_id).uniq.size == expenses.count)
      if all_receipts_avaialble
        # All expenses have receipts
        return 0 if rule.with_receipt_amount.blank?
        return (rule.with_receipt_amount.value - total_expenses), :with_receipt
      else
        # Expenses are present which do not have receipts
        return 0 if rule.without_receipt_amount.blank?
        return (rule.without_receipt_amount.value - total_expenses), :without_receipt
      end
    end
  end

  def check_budget(rule, expense)
    dates = []
    if expense.usage_date_type.blank?
      # Usage date is not set, so pick expense date for budget violation check
      dates << expense.date
    elsif expense.usage_date_end.blank?
      # Only usage start date is set, so use usage_date_start for budget violation check
      dates << expense.usage_date_start
    else
      # Both usage_date_start and usage_date_end is defined, so use all dates in the range for budget check
      dates += (expense.usage_date_start.to_date..expense.usage_date_end.to_date).to_a
    end
    dates.each do |date|
      start_date = nil
      end_date = nil
      if rule.amount&.value or rule.without_receipt_amount&.value or rule.with_receipt_amount&.value
        if rule.period
          # setting the start and end date based on the kind of period set by the user
          if rule.period_id == Period.id_for(:month)
            start_date = date.beginning_of_month
            end_date = date.end_of_month
          elsif rule.period_id == Period.id_for(:week)
            start_date = date.beginning_of_week
            end_date = date.end_of_week
          elsif rule.period_id == Period.id_for(:year)
            start_date = date.beginning_of_year
            end_date = date.end_of_year
          elsif rule.period_id == Period.id_for(:day)
            start_date = end_date = date
          end
          return if rule.categories.present? and not rule.categories.pluck(:id).include?(expense.category_id)
          categories = rule.categories
          field_drop_down_item_ids = nil
          if rule.budget_rule_field_mappings.present?
            field_drop_down_item_ids = rule.budget_rule_field_mappings.pluck(:field_drop_down_item_id)
          end
          available_budget, violation_type = available_budget(expense, rule, start_date, end_date, categories, field_drop_down_item_ids)

          # return if budget rule has any department but do not return if budget rule department and the user department are same
          return if rule.departments.present? and not rule.departments.pluck(:id).any? {|department| expense.user.user_department_mappings.pluck(:department_id).include? department }
          departments = rule.departments

          if available_budget < 0
            type = categories.present? ? 'category' : 'total'
            message = rule.rule_in_words(violation: true, violation_type: violation_type, exceeded_by: available_budget.abs)
            violation_type = (rule.type == 'Warning') ? 'budget_warning' : 'budget_blocking'
            self.warning_messages[expense.id][violation_type] << {type: type, message: message}
          end
        end
      end
    end
  end

  # method that checks for whether a Distance/Time/Per Diem expense is enabled for the particular report policy
  # (or company if no policy is selected) and adds a blocking violation if it's not
  def check_compatible_expenses(expense)
    message = "Expenses are not enabled for the selected policy. Please change the policy of the report or remove the expense"
    case expense.expense_type_id
    when ExpenseType.id_for(:cash)
      unless report.policy.cash_expense_config.enabled
        self.warning_messages[expense.id]['expense_blocking'] << {type: 'incompatible', message: "Cash #{message}"}
        return
      end
    when ExpenseType.id_for(:card)
      unless report.policy.card_expense_config.enabled
        self.warning_messages[expense.id]['expense_blocking'] << {type: 'incompatible', message: "Card #{message}"}
        return
      end
    when ExpenseType.id_for(:distance)
      # unless report.policy.distance_expense_config.enabled
      #   self.warning_messages[expense.id]['expense_blocking'] << {type: 'incompatible', message: "Distance #{message}"}
      #   return
      # end
      if report.policy.distance_expense_config.enabled
        unless report.policy == expense.distance_expense&.vehicle_rate&.policy
          self.warning_messages[expense.id]['expense_blocking'] << {type: 'incompatible', message: "Some Distance Expenses do not belong to the selected policy"}
        end
      else
        self.warning_messages[expense.id]['expense_blocking'] << {type: 'incompatible', message: "Distance #{message}"}
        return
      end
    when ExpenseType.id_for(:time)
      unless report.policy.time_expense_config.enabled
        self.warning_messages[expense.id]['expense_blocking'] << {type: 'incompatible', message: "Time #{message}"}
        return
      end
    when ExpenseType.id_for(:per_diem)
      if report.policy.per_diem_expense_config.enabled
        if report.policy.per_diems.include?(expense.per_diem_expense.per_diem)
          return
        else
          message = "of some expenses do not belong to the selected policy"
          self.warning_messages[expense.id]['expense_blocking'] << {type: 'incompatible', message: "Some Per Diem #{message}"}
        end
      else
        self.warning_messages[expense.id]['expense_blocking'] << {type: 'incompatible', message: "Per Diem #{message}"}
        return
      end
    else
      # do nothing
    end
  end

  def check_non_base_currency(expense)
    if expense.date == DateUtils.local_date and expense&.amount.present?
      if expense&.amount&.currency_id == base_currency_id
        return
      else
        self.warning_messages[expense.id]['expense_blocking'] << {type: 'non_base_currency', message: "Expenses that are reported in a different currency from #{base_currency_code} can only be submitted the next day"}
      end
    end
  end

  def check_custom_fields(expense)
    exp = expense.sub_expense
    valid = CustomField::Validate.(exp)
    unless valid.success?
      valid.messages[:error]&.each do |message|
        self.warning_messages[expense.id]['expense_blocking'] << {type: 'custom_fields', message: message}
      end
    end
  end

  def check_distance_expense(expense)
    return unless expense.distance_expense?
    distance_expense = expense.distance_expense
    unless distance_expense&.distance.present? and distance_expense&.distance&.value > 0
      self.warning_messages[expense.id]['expense_blocking'] << {type: 'distance_expense', message: 'Distance cannot be blank'}
    end
  end

  def check_cash_on_hand_blocked(expense)
    if expense.from_cash_on_hand && !expense.cash_on_hand_blocked
      self.warning_messages[expense.id]['expense_blocking'] << {type: 'cash_on_hand', message: "You do not have enough cash on hand to mark this expense against it"}
    end
  end

end
