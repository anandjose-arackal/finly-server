class Expense::Manual::Split < Expense::Manual::Base
  attr_accessor :expenses_params, :receipt, :expenses, :receipt

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    super
    return if has_errors?
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params&.dig(:expense).blank?
      add_message :error, 'You have not provided any details to create an expense'
      return
    end
    # checking if the report is editable for personal view
    if personal_view? and params.dig(:expense, :report_id).present?
      report = user.reports.find_by(id: params.dig(:expense, :report_id))
      unless report&.editable?
        add_message :error, 'Expense cannot be added to the report in this state'
      end
    end
  end

  def init
    self.expenses_params = split_expense_params
    self.expenses = []
    self.expenses_params&.each do |expense_params|
      expense = user.expenses.build(expense_params[:expense_params])
      unless expense.valid?
        expense.errors.full_messages&.each do |error|
          add_message :error, "Split #{expense_params[:index]}: #{error}"
        end
      end
      return if has_errors?
      # Create custom fields only for validations. Fields will be saved later
      custom_fields = expense_params[:custom_fields]
      if custom_fields.present?
        validate_custom_fields(expense, custom_fields, expense_params[:index])
        unless has_errors?
          self.expenses << expense
        end
      end
      return if has_errors?
    end
  end

  def validate

  end

  def process
    self.expenses.each do |expense|
      if expense.save and self.receipt.present?
        expense.receipts << expense.receipts.create(image: self.receipt.image, user: expense.user)
      end
    end
    if self.receipt.present?
      self.receipt.destroy
    end
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(user, params, messages)
  end

  protected
  def split_expense_params
    expenses_params = []
    base_params = params.require(:expense).permit(:expense_type_id, :expense_status_id,
                                                  :report_id, :reimbursable,
                                                  manual_expense_attributes: [:merchant],
                                                  receipts_attributes: [:image],
                                                  receipt_email_attributes: [:source, :email_id, :sender, :raw_html,
                                                                             :subject, :sent_at, :body,
                                                                             receipt_email_attachments_attributes: [:attachment_url, :attachment_url_file_name, :original_attachment]])

    # Set custom Fields
    base_custom_fields = (params[:custom_fields] or params[:expense][:custom_fields] or {})
    base_params[:expense_type_id] = ExpenseType.id_for(:manual)
    # Keep a copy of the receipt to be attached. Create images for each expenses from the receipt and finally destroy the receipt
    if params&.dig(:expense, :receipt_id).present?
      self.receipt = user.receipts.find_by_id(params&.dig(:expense, :receipt_id))
    elsif base_params[:receipts_attributes].present?
      base_params[:receipts_attributes][:user_id] = user.id
    end
    if base_params[:receipt_email_attributes].present?
      base_params[:receipt_email_attributes][:user_id] = user.id
    end
    params&.dig(:splits)&.each_with_index do |split, index|
      expense_item_params = base_params.deep_dup
      expense_item_params[:note] = split[:note]
      expense_item_params[:category_id] = split[:category_id]
      expense_item_params[:amount_attributes] = split[:amount_attributes]
      expense_item_params[:date] = split[:date]
      expense_custom_fields = base_custom_fields
      if split[:custom_fields].present?
        expense_custom_fields[:custom_fields].merge split[:custom_fields]
      end
      expenses_params << {index: index, expense_params: expense_item_params.permit!, custom_fields: expense_custom_fields.permit!}
    end
    expenses_params
  end

  def validate_custom_fields(expense, custom_fields, index)
    if expense.valid?
      set_fields = set_custom_fields expense, custom_fields, false
      unless set_fields.success?
        set_fields.messages[:error]&.each do |error|
          add_message :error, "Split #{index}: #{error}"
        end
        return
      end
      valid = CustomField::Validate.(expense.manual_expense)
      unless valid.success?
        valid.messages[:error]&.each do |error|
          add_message :error, "Split #{index}: #{error}"
        end
        return
      end
    end
  end

  def set_custom_fields(expense, custom_field_params, save)
    if custom_field_params.blank?
      return
    end
    custom_fields = {custom_fields: custom_field_params}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = save
    CustomField::SetFields.(expense.manual_expense, FieldParentType.id_for(:manual_expense), custom_fields)
  end

end