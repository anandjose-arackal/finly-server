class TestForm < Forms::API

  field_class Expense
  section :header do
    amount :amount, required: true
    date :date, required: true, default: -> {Date.today}
    string :merchant, required: true
    text :note
    property :user_id, required: true
    property :company_id, required: true
    integer :expense_type_id, default: 1, required: true, editable: false, visible: false, options: {configurable: false}
    property :cash_expense, populator: :cash_expense_populator! do
      dropdown :expense_mode, label: "Expense Mode", choices: [{value: "Reimbursement"}, {value: "Cash"}], required: true
      # lookup :tags, choices: [{value: "Reimbursement"}, {value: "Cash"}], options: {multiple: true}
    end
    # collection :tags, populate_if_empty: Tag do
    #   string :name
    # end

    validate :cash_expense_presence
  end

  functions do
    def cash_expense_presence
      if self.expense_type_id == 1 and self.cash_expense.nil?
        errors.add :cash_expense, 'cannot be blank'
      end
    end

    def cash_expense_populator!(options)
      return skip! unless self.expense_type_id == 1#options[:doc]['expense_type_id'] == 1
      if options[:fragment]&.dig(:id).present?
        ManualExpense.find_by(id: options[:fragment]&.dig(:id))
      else
        ManualExpense.new
      end
    end
  end
end