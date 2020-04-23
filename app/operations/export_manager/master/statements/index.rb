class ExportManager::Master::Statements::Index < ExportManager::Builders::Spreadsheet

  label 'Export'
  description 'Statements Export'
  configurable true
  system :em
  screen 'statements.index'
  handle :statements
  validate :input

  attribute :date
  attribute :type
  attribute :purpose
  attribute :merchant
  attribute :merchant_employee_id_id 
  attribute :card_number 
  attribute :credit
  attribute :debit
  attribute :closing_balance
  attribute :status
  attribute :transaction_id
  attribute :note

  def input
    result = ::Statements::Show.(user, params)

    unless result&.success?
      return add_message :error, result.messages[:error]
    end
    
    result.scoped_finly_transactions.success.sort_date_asc
  end

  def date(transaction)
    DateUtils.date_formatted(transaction.transaction_detail&.transaction_date)
  end

  def type(transaction)
    transaction.transaction_detail&.transaction_type&.humanize
  end

  def purpose(transaction)
    transaction.transaction_detail&.payment_purpose&.humanize
  end

  def merchant(transaction)
    transaction.transaction_detail&.merchant
  end

  def merchant_employee_id_id(transaction)
    if transaction.associated_transaction_type.eql?("CardTransaction")
      transaction&.associated_transaction&.user&.employee_id
    else
      ''
    end
  end
    
  def card_number(transaction)
    if transaction.associated_transaction_type.eql?("CardTransaction")
      transaction&.associated_transaction&.serial_id
    else
      ''
    end
  end

  def credit(transaction)
    transaction.transaction_detail&.amount&.value if transaction.credit?
  end

  def debit(transaction)
    transaction.transaction_detail&.amount&.value unless transaction.credit?
  end

  def closing_balance(transaction)
    transaction.transaction_detail&.closing_balance&.value
  end

  def status(transaction)
    transaction.transaction_detail&.status&.humanize
  end

  def transaction_id(transaction)
    transaction.transaction_detail&.transaction_reference_id
  end

  def note(transaction)
    transaction.transaction_detail&.get_note
  end
end