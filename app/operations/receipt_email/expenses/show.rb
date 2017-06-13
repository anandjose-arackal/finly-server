class ReceiptEmail::Expenses::Show < BaseOperation
  attr_accessor :receipt_email, :extracted_data

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params&.dig(:receipt_email)&.dig(:email_id).blank?
      add_message :error, 'Email not found'
      return
    end
  end

  def init
    id = params[:receipt_email][:email_id]
    self.receipt_email = self.user.receipt_emails.find_by(id: id)
  end

  def process
    if self.receipt_email.present?
      self.expense_data_extract = self.receipt_email.expense_data_extract
      merchant = self.expense_data_extract
      amount_value = self.expense_data_extract.amount&.value
      currency_id = self.expense_data_extract.amount&.currency_id
      category_id = self.expense_data_extract.category_id
      note = self.expense_data_extract.note
      datetime = (self.datetime or self.date)
      self.extracted_data = ReceiptEmail::Extractor::Data.new(merchant, amount_value, currency_id, datetime, note, category_id, nil)
    else
      self.extracted_data = ReceiptEmail::Extractor::Extract.(user, html_body: params[:html_body], sender: params[:sender], sent_at: params[:sent_at], subject: params[:subject])
    end
  end

  def success
    params[:receipt_email] = self.receipt_email
    params[:extracted_data] = self.extracted_data
    ReceiptEmail::Expenses::Show::SuccessPresenter.new(user, params, messages)
  end

  class ReceiptEmail::Expenses::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :receipt_email, :extracted_data

    def init
      self.receipt_email = params[:receipt_email]
      self.extracted_data = params[:extracted_data]
    end

  end

end