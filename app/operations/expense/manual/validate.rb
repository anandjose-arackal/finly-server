# Class to create an expense
# format of parameters,

class Expense::Manual::Validate < Expense::Manual::Base
  attr_accessor :expense_params, :receipt

  # only employees can create expenses

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    super

    # To accumulate all errors throughout the operation
    messages[:error_local] = []

    if params.blank?
      add_message :error_local, 'Parameters not present'
    end
    if params[:expense].blank?
      add_message :error_local, 'You have not provided any details to create an expense'
      return
    end


    # BEING HANDLED IN MODEL VALIDATION
    # if params[:expense][:amount_attributes][:value].present?
    #   amount_value = params[:expense][:amount_attributes][:value].to_d rescue nil
    #   if amount_value.present? && amount_value <= 0
    #     add_message :error_local, 'Amount cannot be less than or equal to 0'
    #   end
    # end
  end

  def init
    self.expense_params = manual_expense_params
    self.expense_params[:expense_type_id] = ExpenseType.manual_expense_id
    if params[:receipt_id].present?
      self.receipt = user.receipts.with_id(params[:receipt_id]).first rescue nil
    end
    if expense_params[:receipts_attributes] == [nil] or expense_params[:receipts_attributes] == ['']
      expense_params.delete(:receipts_attributes)
    end
  end

  def validate
    
  end

  def pre_process
    
  end

  def process
    # debugger
    self.expense = user.expenses.new(expense_params)
    add_message :error_local, self.expense.errors.full_messages unless self.expense.valid?

    # Create custom fields only for validations. Fields will be saved later
    validate_custom_fields
    add_message :error, messages[:error_local]
    messages.except!(:error_local)
  end

  def post_process
    # add comment in report if expense is added within report
    # add_message :success, 'Expense is Valid'
  end

  protected
  def validate_custom_fields
    set_fields = set_custom_fields false
    unless set_fields.success?
      add_message :error_local, set_fields.messages[:error]
      return
    end
    valid = CustomField::Validate.(self.expense.manual_expense)
    unless valid.success?
      add_message :error_local, valid.messages[:error]
      return
    end
    # self.expense.manual_expense.custom_fields.destroy
  end

  def set_custom_fields(save)
    custom_fields = {custom_fields: (params[:custom_fields] || params[:expense][:custom_fields])}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = save
    CustomField::SetFields.(self.expense.manual_expense, FieldParentType.id_for(:manual_expense), custom_fields)
  end

  def add_message(type, message)
    return if type.blank? or message.blank? or (type != :error and type != :failure and type != :success and type != :message and type != :notice && type != :error_local)
    clear_messages if self.messages.blank?
    if message.is_a?(Array)
      messages[type].concat message
    elsif message.is_a?(String)
      messages[type] << message
    end
  end

  # def success
  #   Expense::Manual::Create::CreatePresenter.new(expense)
  # end

end
