class Personalizer::Adapters::Company33::Expense33::ManualSplit33::Init < Personalizer::Adapters::Base

  if Rails.env.production?
    TYPE_OF_EXPENSE = '54'
    MODE_OF_PAYMENT = '55'
    UNIT = '56'
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
    TYPE_OF_EXPENSE = '62'
    MODE_OF_PAYMENT = '63'
    UNIT = '64'
    EMPLOYEE_FIELD = '65'
    KIRANA = '66'
    VEGETABLES = '67'
    CATEGORY = '68'
    UNIT_PRICE = '69'
    QUANTITY = '70'

    TYPE_OF_EXPENSE_DAILY_CASH = '69'
    TYPE_OF_EXPENSE_MONTHLY_EXPENSE = '70'
    TYPE_OF_EXPENSE_EMPLOYEE_EXPENSE = '71'

    MODE_OF_PAYMENT_CASH = '72'
    MODE_OF_PAYMENT_CREDIT = '73'
    MODE_OF_PAYMENT_BANK = '74'

    CATEGORY_KIRANA = '218'
    CATEGORY_VEGETABLES = '219'
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

    company_category = current_user.company.categories.with_name(category)&.first

    params&.dig(:splits).each do |key, value|
      # kirana = value.dig(:custom_fields, KIRANA)
      # unless kirana.present?
      #   add_message :error, "Split #{key}: Kirana cannot be blank"
      #   return
      # end
      # vegetables = value.dig(:custom_fields, VEGETABLES)
      # unless vegetables.present?
      #   add_message :error, "Split #{key}: Vegetables cannot be blank"
      #   return
      # end

      if company_category.present?
        value[:category_id] = company_category&.id
      end

      kirana = value.dig(:custom_fields, KIRANA)
      vegetables = value.dig(:custom_fields, VEGETABLES)
      if category&.to_s == CATEGORY_KIRANA
        unless kirana.present?
          add_message :error, "Split #{key}: Kirana cannot be blank"
          return
        end
        if vegetables.present?
          value[:custom_fields][VEGETABLES] = nil
        end
      elsif category&.to_s == CATEGORY_VEGETABLES
        unless vegetables.present?
          add_message :error, "Split #{key}: Vegetables cannot be blank"
          return
        end
        if kirana.present?
          value[:custom_fields][KIRANA] = nil
        end
      else
        if vegetables.present?
          value[:custom_fields][VEGETABLES] = nil
        end
        if kirana.present?
          value[:custom_fields][KIRANA] = nil
        end
      end
    end
  end

  def init_monthly_employee
    global_custom_fields = (params&.dig(:custom_fields) or params&.dig(:expense, :custom_fields) or {})
    type_of_expense = global_custom_fields[TYPE_OF_EXPENSE]
    return if type_of_expense == TYPE_OF_EXPENSE_DAILY_CASH
    params&.dig(:splits).each do |key, value|
      value[:custom_fields] = nil
    end
  end

  def init_daily_cash
    global_custom_fields = (params&.dig(:custom_fields) or params&.dig(:expense, :custom_fields) or {})
    type_of_expense = global_custom_fields[TYPE_OF_EXPENSE]
    return unless type_of_expense == TYPE_OF_EXPENSE_DAILY_CASH

    #Split Expense
    params&.dig(:splits).each do |key, value|
      validate_daily_cash(key, value)
    end
  end

  def validate_daily_cash(key, value)
    unit = value.dig(:custom_fields, UNIT)
    prefix = ''
    if key.present?
      prefix = "Split #{key}: "
    end
    unless unit.present?
      add_message :error, "#{prefix}Unit cannot be blank"
      return
    end
    quantity = value.dig(:custom_fields, QUANTITY)
    unless quantity.present?
      add_message :error, "#{prefix}Quantity cannot be blank"
      return
    end
    unless StringUtils.is_number? quantity
      add_message :error, "#{prefix}Quantity is not a number"
      return
    end
    unit_price = value.dig(:custom_fields, UNIT_PRICE)
    unless unit_price.present?
      add_message :error, "#{prefix}Unit Price cannot be blank"
      return
    end
    unless StringUtils.is_number? unit_price
      add_message :error, "#{prefix}Unit Price is not a number"
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
  end

  def process
    params&.dig(:splits).each do |key, value|
      quantity = value.dig(:custom_fields, QUANTITY)
      price_per_quantity = value.dig(:custom_fields, UNIT_PRICE)
      if quantity.present? and price_per_quantity.present?
        value[:amount_attributes][:value] = (quantity.to_i * price_per_quantity.to_i)
      end
    end
  end

  def is_split?

  end

end