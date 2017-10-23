class Personalizer::Adapters::Company33::Expense33::ManualCreate33::PreValidate < Personalizer::Adapters::Base

  if Rails.env.production?
    TYPE_OF_EXPENSE = '54'
    MODE_OF_PAYMENT = '55'
    UNIT = '64'
    CATEGORY = '57'
    EMPLOYEE_FIELD = '58'
    KIRANA = '59'
    VEGETABLES = '60'
    UNIT_PRICE = '61'
    QUANTITY = '62'

    TYPE_OF_EXPENSE_DAILY_CASH = '62'
    TYPE_OF_EXPENSE_MONTHLY_EXPENSE = '63'
    TYPE_OF_EXPENSE_EMPLOYEE_EXPENSE = '64'

    MODE_OF_PAYMENT_CASH = '65'
    MODE_OF_PAYMENT_CREDIT = '66'
    MODE_OF_PAYMENT_BANK = '67'

    CATEGORY_KIRANA = '72'
    CATEGORY_VEGETABLES = '73'
  else
    TYPE_OF_EXPENSE = '54'
    MODE_OF_PAYMENT = '55'
    UNIT = '64'
    CATEGORY = '57'
    EMPLOYEE_FIELD = '58'
    KIRANA = '59'
    VEGETABLES = '60'
    UNIT_PRICE = '61'
    QUANTITY = '62'

    TYPE_OF_EXPENSE_DAILY_CASH = '62'
    TYPE_OF_EXPENSE_MONTHLY_EXPENSE = '63'
    TYPE_OF_EXPENSE_EMPLOYEE_EXPENSE = '64'

    MODE_OF_PAYMENT_CASH = '65'
    MODE_OF_PAYMENT_CREDIT = '66'
    MODE_OF_PAYMENT_BANK = '67'

    CATEGORY_KIRANA = '72'
    CATEGORY_VEGETABLES = '73'
  end


  def pre_validate
    if params.blank?
      add_message :error, 'Error loading configuration'
    end
  end

  def init
    init_category
    init_daily_cash
    init_employee
    init_monthly_employee
  end

  def init_category
    global_custom_fields = (params&.dig(:custom_fields) or params&.dig(:expense, :custom_fields) or {})
    category = global_custom_fields[CATEGORY]
    if category.blank?
      add_message :error, 'Category cannot be blank'
      return
    end
    category_name = FieldDropDownItem.find_by_id(category)&.name
    company_category = current_user.company.categories.with_name(category_name)&.first
    if company_category.present?
      params[:expense][:category_id] = company_category.id
    end

    kirana = global_custom_fields[KIRANA]
    vegetables = global_custom_fields[VEGETABLES]
    if category&.to_s == CATEGORY_KIRANA
      unless kirana.present?
        add_message :error, "Kirana cannot be blank"
        return
      end
      if vegetables.present?
        global_custom_fields[VEGETABLES] = nil
      end
    elsif category&.to_s == CATEGORY_VEGETABLES
      unless vegetables.present?
        add_message :error, "Vegetables cannot be blank"
        return
      end
      if kirana.present?
        global_custom_fields[KIRANA] = nil
      end
    else
      if vegetables.present?
        global_custom_fields[VEGETABLES] = nil
      end
      if kirana.present?
        global_custom_fields[KIRANA] = nil
      end
    end
  end

  def init_monthly_employee
    # global_custom_fields = (params&.dig(:custom_fields) or params&.dig(:expense, :custom_fields) or {})
    # type_of_expense = global_custom_fields[TYPE_OF_EXPENSE]
    # return if type_of_expense == TYPE_OF_EXPENSE_DAILY_CASH
    # params&.dig(:splits).each do |key, value|
    #   value[:custom_fields] = nil
    # end
  end

  def init_daily_cash
    global_custom_fields = (params&.dig(:custom_fields) or params&.dig(:expense, :custom_fields) or {})
    type_of_expense = global_custom_fields[TYPE_OF_EXPENSE]
    return unless type_of_expense == TYPE_OF_EXPENSE_DAILY_CASH
    validate_daily_cash(global_custom_fields)
  end

  def validate_daily_cash(value)
    unit = value.dig(UNIT)
    unless unit.present?
      add_message :error, "Unit cannot be blank"
      return
    end
    quantity = value.dig(QUANTITY)
    unless quantity.present?
      add_message :error, "Quantity cannot be blank"
      return
    end
    unless StringUtils.is_number? quantity
      add_message :error, "Quantity is not a number"
      return
    end
    unit_price = value.dig(UNIT_PRICE)
    unless unit_price.present?
      add_message :error, "Unit Price cannot be blank"
      return
    end
    unless StringUtils.is_number? unit_price
      add_message :error, "Unit Price is not a number"
      return
    end
    if has_errors?
      return
    end
  end

  def init_employee
    global_custom_fields = (params&.dig(:custom_fields) or params&.dig(:expense, :custom_fields) or {})
    type_of_expense = global_custom_fields[TYPE_OF_EXPENSE]
    return unless type_of_expense == TYPE_OF_EXPENSE_EMPLOYEE_EXPENSE
    if global_custom_fields[EMPLOYEE_FIELD].blank?
      add_message :error, 'Employee has not been selected for an Employee Expense'
      return
    end
    employee = FieldDropDownItem.find_by_id(global_custom_fields[EMPLOYEE_FIELD])&.name
    params[:expense][:manual_expense_attributes][:merchant] = "Employee Exp: #{employee}"
  end

  def process
    global_custom_fields = (params&.dig(:custom_fields) or params&.dig(:expense, :custom_fields) or {})
    quantity = global_custom_fields[QUANTITY]
    price_per_quantity = global_custom_fields[UNIT_PRICE]
    if quantity.present? and price_per_quantity.present?
      params[:expense][:amount_attributes][:value] = (quantity.to_i * price_per_quantity.to_i)
    end
  end

end