class Expense::Manual::Split < Expense::Manual::Base
  attr_accessor :expenses_params, :receipt, :expenses, :receipt, :split_link

  class Expense::Manual::Split::SplitPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :expenses

    def init
      self.expenses = params[:expenses]
    end
  end

  def personalizer
    {
        init: {
            before: Personalizer::Process.new([:expense, :manual_split], :init, self)
        }
    }
  end

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
      unless report&.editable? or (report&.controlling_user_id == user.id and report&.processing?)
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
      else
        self.expenses << expense
      end
      return if has_errors?
    end
    generate_split_link
  end

  def validate
    if self.expenses_params.blank?
      add_message :error, 'Split expense details cannot be empty'
    end
  end

  def process
    self.expenses.each do |expense|
      expense.split_link = self.split_link
      if expense.save and self.receipt.present?
        expense.receipts << expense.receipts.create(image: self.receipt.image, user: expense.user)

        # calculate the equivalent amount in all currencies in the amounts table
        if expense.date == DateUtils.local_date
          expense.amount.update(expense.amount.currency.country_code.to_sym => expense.amount_value)
        else
          expense.update_other_currencies
        end
      end
    end
    if self.receipt.present?
      self.receipt.destroy
    end
  end

  def success
    params[:expenses] = self.expenses
    Expense::Manual::Split::SplitPresenter.new(user, params, messages)
  end



  protected
  def generate_split_link
    split_link_prefix = "#{Date.today.strftime('%y%m%d')}#{user.id}"
    while self.split_link.blank? or Expense.with_split_link(self.split_link).present?
      self.split_link = "#{split_link_prefix}#{Generator.random_number(5)}"
    end
  end

  def split_expense_params
    expenses_params = []
    base_params = params.require(:expense).permit(:expense_type_id, :expense_status_id,
                                                  :report_id, :reimbursable, :date, :spent_from_id, :created_by_id,
                                                  manual_expense_attributes: [:merchant],
                                                  card_expense_attributes: [:editable_merchant, :card_transaction_id],
                                                  receipts_attributes: [:image],
                                                  receipt_email_attributes: [:source, :email_id, :sender, :raw_html,
                                                                             :subject, :sent_at, :body,
                                                                             receipt_email_attachments_attributes: [:attachment_url, :attachment_url_file_name, :original_attachment]])

    # Set custom Fields
    base_custom_fields = (params[:custom_fields] or params[:expense][:custom_fields] or {})
    base_params[:expense_type_id] = expense_type_id
    # Keep a copy of the receipt to be attached. Create images for each expenses from the receipt and finally destroy the receipt
    receipt_id = self.receipt_id
    if receipt_id.present?
      load_receipt
    elsif base_params[:receipts_attributes].present?
      base_params[:receipts_attributes][:user_id] = user.id
    end
    if base_params[:receipt_email_attributes].present?
      base_params[:receipt_email_attributes][:user_id] = user.id
    end
    splits = params&.dig(:splits)
    splits&.each do |index, split|
      expense_item_params = base_params.deep_dup
      expense_item_params[:note] = split[:note]
      expense_item_params[:category_id] = split[:category_id]
      expense_item_params[:created_by_id] = actual_current_user.id if actual_current_user.present?
      expense_item_params[:amount_attributes] = split[:amount_attributes] if split[:amount_attributes].present?
      expense_custom_fields = base_custom_fields.deep_dup
      if split[:custom_fields].present?
        expense_custom_fields.merge! split[:custom_fields]
        # split[:custom_fields]&.each do |key, value|
        #   expense_custom_fields[key] = value
        # end
      end
      if expense_item_params.present?
        expense_item_params = (expense_item_params.permit! rescue expense_item_params)
      end
      if expense_custom_fields.present?
        expense_custom_fields = (expense_custom_fields.permit! rescue expense_custom_fields)
      end
      expenses_params << {index: index, expense_params: expense_item_params, custom_fields: expense_custom_fields}
    end
    expenses_params
  end


  def validate_custom_fields(expense, custom_fields, index)
    if expense.valid?
      set_fields = set_custom_fields expense, custom_fields, false
      unless set_fields.success?
        set_fields.messages[:error]&.each do |error|
          add_message :error, "Split #{(index)}: #{error}"
        end
        return
      end
      valid = CustomField::Validate.(expense.sub_expense)
      unless valid.success?
        valid.messages[:error]&.each do |error|
          add_message :error, "Split #{(index)}: #{error}"
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
    parent_type = nil
    case expense.expense_type_id
      when ExpenseType.id_for(:manual)
        parent_type = :manual_expense
      when ExpenseType.id_for(:card)
        parent_type = :card_expense
      when ExpenseType.id_for(:distance)
        parent_type = :distance_expense
      when ExpenseType.id_for(:time)
        parent_type = :time_expense
      when ExpenseType.id_for(:per_diem)
        parent_type = :per_diem_expense
    end
    CustomField::SetFields.(expense.sub_expense, FieldParentType.id_for(parent_type), custom_fields)
  end

  def expense_type_id
    ExpenseType.id_for(:manual)
  end

  def receipt_id
    (params&.dig(:expense, :receipt_id) or params&.dig(:receipt_id))
  end

  def load_receipt
    self.receipt = user.receipts.without_parent.find_by_id(receipt_id)
  end

end