class Expense::Base < BaseOperation
  attr_accessor :expense, :per_diem, :cash_pocket, :violations, :budget_contributions_before_update

  def authorized_user_types
    [:employee, :manager, :admin, :finance_manager]
  end

  def pre_validate
    if user.blank?
      messages[:error] << 'User not found'
    end
    validate_delegator_action if actual_current_user.present?
  end

  def init
    id = (params[:expense_id] or params[:id])
    self.expense = Expense::Index.(user, params)&.expenses&.find_by(id: id)
  end

  def check_coh_availability_create(pocket, params = {})

    unless pocket.cash_pocket?
      return
    end

    # first checking if the currencies of the expense and the pocket are the same
    currency_id = params&.dig(:amount_attributes, :currency_id)&.to_i
    pocket_currency_id = pocket.base_currency_id
    # i.e. only if both the base currencies are present do we check for the pocket compatibility
    if pocket_currency_id.present? && currency_id.present?
      unless currency_id == pocket_currency_id
        add_message :error, "Expense and spend account should be of the same currency. Please change the currency or choose a different spend account"
        return
      end
    end

    # if the expense is from cash on hand, ensure the user has enough cash on hand to make it
    if params[:spent_from_id].present? || StringUtils.to_bool(params[:from_cash_on_hand])

      # todo - temporary to support mobile APIs
      params[:spent_from_id] = pocket.id if (StringUtils.to_bool(params[:from_cash_on_hand]) && params[:spent_from_id].blank?)

      # for Manual Expenses ONLY
      # first check if the expense is being created in non-INR, and if its date is today
      if params[:expense_type_id] == ExpenseType.id_for(:manual)
        if params[:date].present? && (Date.parse(params[:date]) == DateUtils.local_date) && !([pocket.base_currency_id, pocket.base_currency_id.to_s].include?(params&.dig(:amount_attributes, :currency_id)))
          add_message :error, "#{pocket.name} expenses that are in a currency different from #{pocket.base_currency.country_code} can only be reported on the next day"
          return
        end
      end

      case params[:expense_type_id]
        when ExpenseType.id_for(:manual)
          amount = params[:amount_attributes][:value]&.to_f
        # currency_id = Currency.find_by(id: params[:amount_attributes][:currency_id])
        # rate = CurrencyConversionRate.find_by(date: date)
        when ExpenseType.id_for(:per_diem)
          expense = user.expenses.build(params)
          amount = expense.calculate_amount_value(self.per_diem.configurable)
        when ExpenseType.id_for(:distance)
          expense = user.expenses.build(params)
          amount = expense.calculate_amount_value(nil)
        when ExpenseType.id_for(:time)
          expense = user.expenses.build(params)
          if expense.report.present?
            amount = expense.calculate_amount_value(expense.report.policy)
          else
            amount = 0
          end
      end
      cash_pocket_adapter = AccountManager::CashPockets::CashPocketsAdapter.new(pocket)
      balance = cash_pocket_adapter.balance(display_balance: true) # because we need the balances after reducing the other expenses blocked amount
      unless balance >= amount
        add_message :error, "You do not have enough balance in your #{pocket.name} account to mark this expense against it"
        return
      end
    end
  end

  # common conditions for checking amounts against cash on hand
  def check_coh_availability_update(pocket, params = nil)

    unless pocket&.cash_pocket?
      return
    end

    # first checking if the currencies of the expense and the pocket are the same
    currency_id = params&.dig(:amount_attributes, :currency_id)&.to_i
    pocket_currency_id = pocket.base_currency_id
    if pocket_currency_id.present? && currency_id.present?
      unless currency_id == pocket_currency_id
        add_message :error, "Expense and spend account should be of the same currency. Please change the currency or choose a different spend account"
        return
      end
    end

    # if the expense is being marked as from cash on hand, check if there is enough cash on hand to facilitate it
    if (params&.dig(:spent_from_id).present? or StringUtils.to_bool(params[:from_cash_on_hand])) or ((params&.dig(:spent_from_id).nil? or (params.has_key?(:from_cash_on_hand) and !StringUtils.to_bool(params[:from_cash_on_hand]))) and expense.spent_from.present?)

      # # first check if the expense is being created in non-INR, and if its date is today
      # if params[:date].present? && (Date.parse(params[:date]) == DateUtils.local_date) && !([1, '1'].include?(params&.dig(:amount_attributes, :currency_id)))
      #   add_message :error, "Cash on hand expenses that are in a currency different from INR can only be reported on the next day"
      #   return
      # end


      #params[:spent_from_id] = nil unless (StringUtils.to_bool(params[:from_cash_on_hand]) || params[:spent_from_id].present?) # this is so that if the expense is marked as NOT from COH, it will get updated accordingly from the mobile APIs

      if pocket.present?
        # todo - temporary to support mobile APIs
        params[:spent_from_id] = pocket&.id if (StringUtils.to_bool(params[:from_cash_on_hand]) && params[:spent_from_id].blank?)

        cash_pocket_adapter = AccountManager::CashPockets::CashPocketsAdapter.new(pocket)
        amount_val = (params&.dig(:amount_attributes, :value)&.to_f || expense.amount&.value)
        balance = cash_pocket_adapter.balance(display_balance: true) # because we need the balances after reducing the other expenses blocked amount
        # if the expense is continuing to be from COH, and only the amount is changing
        if expense.spent_from.present? && (params&.dig(:spent_from_id).present? or StringUtils.to_bool(params[:from_cash_on_hand])) && params&.dig(:amount_attributes, :value).present?
          # If amount is not changed but only the Spent From, then the difference should not be calculated. So assign the whole amount to difference.
          difference = if params&.dig(:amount_attributes, :value)&.to_f == expense.amount_value&.to_f
            params&.dig(:amount_attributes, :value)&.to_f
          else
            params&.dig(:amount_attributes, :value)&.to_f - expense.amount_value
          end

          if difference > balance
            add_message :error, "You do not have enough balance in your #{pocket.name} account to mark this expense against it"
            return
          end
          # i.e. if the expense was not originally from COH, and it's currently being made into one
        elsif !expense.spent_from.present? && (params&.dig(:spent_from_id).present? or StringUtils.to_bool(params[:from_cash_on_hand]))
          unless balance >= amount_val
            add_message :error, "You do not have enough balance in your #{pocket.name} account to mark this expense against it"
            return
          end
        elsif expense.spent_from.present? && !(params&.dig(:spent_from_id).present? or StringUtils.to_bool(params[:from_cash_on_hand]))
          # nothing to do here ¯\_(ツ)_/¯
        end
      end
    end
  end

  # ensuring that the an expense can't be both from cash on hand AND reimbursable during updation
  def check_coh_reimbursable_exclusivity_update(params)
    # making sure that a particular expense cannot be both reimbursable and from cash on hand at the same time
    from_cash_pockets = params&.dig(:spent_from_id).present? or StringUtils.to_bool(params[:from_cash_on_hand])
    # from_cash_pockets = from_cash_pockets.blank? ? (expense.spent_from&.present? or StringUtils.to_bool(params[:from_cash_on_hand])) : from_cash_pockets
    reimbursable = StringUtils.to_bool(params&.dig(:reimbursable))
    reimbursable = reimbursable.nil? ?  expense.reimbursable : reimbursable
    # if from_cash_pockets and reimbursable
    #   add_message :error, 'Expense cannot be Reimbursable and Paid from Cash on Hand'
    # end
  end

  # ensuring that the an expense can't be both from cash on hand AND reimbursable during creation
  def check_coh_reimbursable_exclusivity_create(params)
    if (params[:spent_from_id].present? or StringUtils.to_bool(params[:from_cash_on_hand])) && StringUtils.to_bool(params[:reimbursable])
      add_message :error, "Expense spent from cash on hand cannot be reimbursable"
    end
  end

  def check_for_violations
    if expense.report.present?
      self.violations = Reports::Violation.(user, report: expense.report)
    end
  end

  def has_warning?
    return false unless self.violations.present?
    self.violations.each do |key, violation|
      if violation[:expense_warning].present? or violation[:budget_warning].present? or
          violation['expense_warning'].present? or violation['budget_warning'].present?
        return true
      end
    end
    false
  end

  def fetch_budget_contributions(expense)
    if user.company.enforce_budget_configuration.enforce_expense_budget?
      op = BudgetManager::BudgetLimitValidator::Expense.({expense: expense, ignore_unbudgetables: true, current_user: user})
      self.budget_contributions_before_update = op['result'][:budget_contributions] rescue {}
    end
  end

  def budget_limit_validation(expense)
    if user.company.enforce_budget_configuration.enforce_expense_budget?
      return BudgetManager::BudgetLimitValidator::Expense.({expense: expense, previous_budget_contributions: self.budget_contributions_before_update, current_user: user})
    end
  end

  def success
    Expense::Base::Presenter.new(user, {expense: self.expense, view: params[:view]}, self.messages)
  end

  # def destroy_irrelevant_dependent_cf(expense_obj, field_configuration = nil)
  #   if field_configuration.blank?
  #     return
  #   end
  #   # basically loop through the custom field dropdown items and see if there is
  #   # a dependent custom field, and if there isn't destroy the associated custom fields
  #   # associated with expense_obj
  #   drop_down_ids = []
  #   expense_obj.custom_fields.drop_down_custom_fields_only.only_non_root_field_configs.each do |cf|
  #     drop_down_ids << cf.value.value.id # i.e. the cf -> field drop down selection -> field drop down item -> id
  #   end
  #   field_config_ids = expense_obj.custom_fields.only_non_root_field_configs.pluck(:field_configuration_id)
  #   field_configs = current_company.field_configurations.with_id(field_config_ids).order(id: :asc)
  #   field_configs.each do |field_config|
  #     # i.e. this particular field configuration's parent id is not in the list of
  #     # drop down ids that are associated with this expense
  #     if !field_config.root_field && !drop_down_ids.include?(field_config.parent_id)
  #       cf = expense_obj.custom_fields.with_field_configuration_ids(field_config.id).first
  #       cf.destroy
  #     end
  #   end
  # end

  class Expense::Base::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :expense, :violation, :editable, :view, :per_diems, :converted,
                  :conversion_rate, :em_tax_tracking, :tds_slabs, :vehicle_rates,
                  :cash_pockets, :tax_rates, :gst_state_codes


    def init
      self.expense = params[:expense]
      self.view = params[:view]
      self.violation = retrieve_violation
      self.editable = retrieve_editable
      self.per_diems = retrieve_per_diems(expense)
      self.vehicle_rates = retrieve_vehicle_rates(expense)
      self.converted = expense.converted?
      self.conversion_rate = expense.conversion_rate
      self.cash_pockets = expense.user.user_pockets.non_bank_card_transfer_pockets.active
      self.tax_rates = expense.user.company.tax_rates
      self.gst_state_codes = GstStateCode.all
    end

    def retrieve_vehicle_rates(expense)
      if expense.report.nil?
        user.vehicle_rates_list
      else
        expense.report.policy.vehicle_rates
      end
    end

    def retrieve_per_diems(expense)
      if expense.report.nil?
        return user.per_diems_list
      else
        if expense.report.policy.present?
          policy = expense.report.policy
          per_diems = policy.per_diems
        else
          company = user.company
          per_diems = company.per_diems
        end
        return per_diems
      end
    end

    def retrieve_violation
      violations = {blocking_present: false, warning_present: false, items: []}
      if expense.report_id and expense.report&.policy
        violations = Reports::Violation.(user, report: expense.report)
        items = violations[expense.id]
        # constructing the violation hash as required
        violations = {}
        violations[:blocking_present] = (items&.dig(:expense_warning).present? or items&.dig(:budget_warning).present? or items&.dig('expense_warning').present? or items&.dig('budget_warning').present?)
        violations[:warning_present] = (items&.dig(:expense_blocking).present? or items&.dig(:budget_blocking).present? or items&.dig('expense_blocking').present? or items&.dig('budget_blocking').present?)
        violations[:items] = items
      end
      violations
    end

    def calculate_conversion_rate
      if expense.report.nil?
        return nil
      else
        converted_amount = expense.amount_value
        original_amount = expense.original_amount_value
        return precision_value converted_amount/original_amount
      end
    end

    def retrieve_editable
      if personal_view?
        if expense.report.blank? or expense.report&.editable?
          return true
        end
      end
      if expense.report_id.present? and expense.report.present? and expense.report&.processing? and expense.report&.get_reviewers.pluck(:id).include?(user.id)
        return true
      end
      false
    end

    def start_receipt
      receipt = expense.distance_expense&.odometer_reading_receipt_start
      return nil unless receipt.present?
      {
          id: receipt.id,
          image: {
              file_type: receipt.file_format,
              original: receipt.image.url,
              thumb: receipt.image.url(:thumb)
          }
      }
    end

    def end_receipt
      receipt = expense.distance_expense&.odometer_reading_receipt_end
      return nil unless receipt.present?
      {
          id: receipt.id,
          image: {
              file_type: receipt.file_format,
              original: receipt.image.url,
              thumb: receipt.image.url(:thumb)
          }
      }
    end

    def cash_pockets
      list = []
      expense.user.user_pockets.non_bank_card_transfer_pockets.include_details.each do |pocket|
        hash = {}
        if pocket.cash_pocket?
          adapter = AccountManager::CashPockets::CashPocketsAdapter.new(pocket)
          hash[:balance] = adapter&.balance(display_balance: true)
          hash[:display_balance] = true
        elsif pocket.credit_card_pocket?
          hash[:balance] = 0
          hash[:display_balance] = false
        end
        hash[:name] = pocket.name
        hash[:id] = pocket.id

        currency = pocket.base_currency
        hash[:base_currency] = {
            symbol: currency&.symbol,
            country_code: currency&.country_code,
            id: currency&.id
        }
        list << hash
      end
      list
    end

  end

end