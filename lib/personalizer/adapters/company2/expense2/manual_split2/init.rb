class Personalizer::Adapters::Company2::Expense2::ManualSplit2::Init < Personalizer::Adapters::Base

  TYPE_OF_EXPENSE = '53'
  EMPLOYEE_EXPENSE = '166'

  EMPLOYEES_FIELD = '56'

  DAILY_CASH = '164'
  QUANTITY = '59'
  UNIT_PRICE = '60'

  UNIT = '55'
  KIRANA = '57'
  VEGETABLES = '58'

  CATEGORY = ''

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

    category_id = params&.dig(:expense, :category_id)
    category = Category.find_by_id(category_id)
    kirana = value.dig(:custom_fields, KIRANA)
    vegetables = value.dig(:custom_fields, VEGETABLES)
    if category.name == 'Kirana'
      unless kirana.present?
        add_message :error, "Split #{key}: Kirana cannot be blank"
        return
      end
      if vegetables.present?
        value[:custom_fields][VEGETABLES] = nil
      end
    elsif category.name == 'Vegetables and Fruits'
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
    params&.dig(:splits).each do |key, value|
      kirana = value.dig(:custom_fields, KIRANA)
      unless kirana.present?
        add_message :error, "Split #{key}: Kirana cannot be blank"
        return
      end
      vegetables = value.dig(:custom_fields, VEGETABLES)
      unless vegetables.present?
        add_message :error, "Split #{key}: Vegetables cannot be blank"
        return
      end
    end
  end

  def init_monthly_employee
    global_custom_fields = (params&.dig(:custom_fields) or params&.dig(:expense, :custom_fields) or {})
    type_of_expense = global_custom_fields[TYPE_OF_EXPENSE]
    return if type_of_expense == DAILY_CASH
    params&.dig(:splits).each do |key, value|
      value[:custom_fields] = nil
    end
  end

  def init_daily_cash
    global_custom_fields = (params&.dig(:custom_fields) or params&.dig(:expense, :custom_fields) or {})
    type_of_expense = global_custom_fields[TYPE_OF_EXPENSE]
    return unless type_of_expense == DAILY_CASH
    params&.dig(:splits).each do |key, value|
      unit = value.dig(:custom_fields, UNIT)
      unless unit.present?
        add_message :error, "Split #{key}: Unit cannot be blank"
        return
      end
      quantity = value.dig(:custom_fields, QUANTITY)
      unless quantity.present?
        add_message :error, "Split #{key}: Quantity cannot be blank"
        return
      end
      unless StringUtils.is_number? quantity
        add_message :error, "Split #{key}: Quantity is not a number"
        return
      end
      unit_price = value.dig(:custom_fields, UNIT_PRICE)
      unless unit_price.present?
        add_message :error, "Split #{key}: Unit Price cannot be blank"
        return
      end
      unless StringUtils.is_number? unit_price
        add_message :error, "Split #{key}: Unit Price is not a number"
        return
      end
      if has_errors?
        return
      end
    end
  end

  def init_employee
    global_custom_fields = (params&.dig(:custom_fields) or params&.dig(:expense, :custom_fields) or {})
    type_of_expense = global_custom_fields[TYPE_OF_EXPENSE]
    return unless type_of_expense == EMPLOYEE_EXPENSE
    if global_custom_fields[EMPLOYEES_FIELD].blank?
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

end