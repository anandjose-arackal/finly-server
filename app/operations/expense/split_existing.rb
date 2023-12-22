class Expense::SplitExisting < Expense::Manual::Split
  attr_accessor :expenses_params, :receipt, :expenses, :receipt, :split_link, :existing_expense

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    super
    return if has_errors?
    if params[:expense_id].blank?
      add_message :error, 'Expense not found'
      return
    end
  end

  def init
    result = Expense::Show.(user, id: params[:expense_id], view: params[:view])
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.existing_expense = result.expense
    return unless self.existing_expense.present?
    if self.existing_expense.card_expense?
      if params&.dig(:expense, :card_expense_attributes).present?
        params[:expense][:card_expense_attributes][:card_transaction_id] = self.existing_expense.card_expense&.card_transaction_id
      end
      if params[:expense].present?
        params[:expense][:date] = DateUtils.date_formatted(self.existing_expense.date)
      end
    end
    super
  end

  def validate
    super
    return if has_errors?
    if params[:expense_id].present? and self.existing_expense.blank?
      add_message :error, 'Expense not found'
      return
    end

    # validate expense that is being split is an Card or Cash Expense
    unless self.existing_expense.card_expense? or self.existing_expense.manual_expense?
      add_message :error, 'This expense cannot be split. Only Cash and Card expenses can be split'
      return
    end

    # Validate split currency cannot be different from original expense currency
    currency_id = self.existing_expense.amount.currency_id
    self.expenses&.each_with_index do |expense, index|
      unless expense&.amount&.currency_id == currency_id
        add_message :error, "Split #{(index + 1)}: Cannot split expense with a different Currency ID"
        return
      end
    end

    # Validate that the sum of split is equal to existing expenses
    total = 0
    self.expenses&.each do |expense|
      value = expense.amount&.value
      total += value if StringUtils.is_number?(value)
    end
    unless total == self.existing_expense.amount&.value
      add_message :error, "Split amount is not matching the expense total. Split Total: #{total}, Expense Total: #{self.existing_expense.amount&.value}"
      return
    end

    # If Parent category is selected while having children, then the children (subcategory) needs to be selected
    parent_categories_selected = self.expenses.map { |expense| expense.category.name if expense.category.child_ids.present? }.compact
    unless parent_categories_selected.blank?
      add_message :error, "Sub Categories not selected. Please select a subcategory for #{parent_categories_selected.join(', ')}"
      return
    end
  end

  def post_process
    super
    self.existing_expense.receipts.each do |receipt|
      self.expenses.each do|expense|
        expense.receipts.create(image: receipt.image, user: expense.user)
      end
    end
    self.existing_expense.update(deleted_to_split: true, split_link: self.split_link, deleted_at: Time.now)
  end

  def expense_type_id
    self.existing_expense&.expense_type_id
  end

  def receipt_id
    params[:receipt_id]
  end

  def load_receipt
    if self.existing_expense&.receipts&.first&.id == self.receipt_id
      self.existing_expense.receipts.first
    else
      super
    end
  end

  protected
  def generate_split_link
    self.split_link = self.existing_expense&.split_link
    if split_link.blank?
      super
    end
  end

end