class Receipt::ReceiptEmails::Extractor::Data < BaseOperation::BasePresenter::SuccessPresenter
  attr_accessor :merchant, :amount_value, :currency_id, :datetime, :note, :category_id, :status_id

  def initialize(merchant, amount_value, currency_id, datetime, note, category_id, status_id)
    self.merchant = merchant
    self.amount_value = amount_value
    self.currency_id = currency_id
    self.datetime = datetime
    self.note = note
    self.category_id = category_id
    self.status_id = status_id
  end

  def expense_data_extract_params
    {
        amount_attributes:
            {
                value: amount_value,
                currency_id: currency_id
            },
        merchant: merchant,
        category_id: category_id,
        datetime: datetime,
        note: note,
        status_id: status_id,
        expense_data_extract_source_id: ExpenseDataExtractSource.id_for(:auto_extract_email)
    }
  end

  def save_data_extract(receipt_email)
    return unless receipt_email.present?
    data_extract = receipt_email.expense_data_extracts.new self.expense_data_extract_params
    data_extract.save
    data_extract
  end

  def partial_match?
    # if complete_match?
    #   return false
    # elsif self.merchant.present? or self.amount_value.present? or self.currency_id.present? or self.datetime.present? or self.category_id.present?
    #   return true
    # end
    # false
    !complete_match?
  end

  def complete_match?
    if self.merchant.present? and self.amount_value.present? and self.currency_id.present? and self.datetime.present? and self.category_id.present?
      return true
    end
    false
  end

end