class Receipt::ReceiptEmails::Show < BaseOperation
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
    self.receipt_email = self.user.receipt_emails.with_email_id(id)&.first
  end

  def process
    if self.receipt_email.present? and self.receipt_email.expense_data_extracts.present?
      expense_data_extract = self.receipt_email.expense_data_extracts&.first
      merchant = expense_data_extract
      amount_value = expense_data_extract.amount&.value
      currency_id = expense_data_extract.amount&.currency_id
      category_id = expense_data_extract.category_id
      note = expense_data_extract.note
      datetime = (expense_data_extract.datetime or expense_data_extract.date)
      self.extracted_data = Receipt::ReceiptEmails::Extractor::Data.new(merchant, amount_value, currency_id, datetime, note, category_id, nil)
    else
      self.extracted_data = Receipt::ReceiptEmails::Extractor::Extract.(user, html_body: params[:html_body], sender: params[:sender], sent_at: params[:sent_at], subject: params[:subject])
      unless self.extracted_data.success?
        add_message :error, self.extracted_data.messages[:error]
      end
    end
  end

  def success
    params[:receipt_email] = self.receipt_email
    params[:extracted_data] = self.extracted_data
    Receipt::ReceiptEmails::Show::SuccessPresenter.new(user, params, messages)
  end

  class Receipt::ReceiptEmails::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :receipt_email, :extracted_data

    def init
      self.receipt_email = params[:receipt_email]
      self.extracted_data = params[:extracted_data]
    end

    def data
      data = {}
      if self.receipt_email&.expense.present? and self.receipt_email&.expense&.manual_expense.present?
        expense = self.receipt_email.expense
        custom_fields = expense.manual_expense&.custom_fields
        data = {
            id: expense.id,
            merchant: expense.manual_expense.merchant_name,
            date: DateUtils.date_formatted(expense.date),
            note: expense.note,
            # note: nil,
            category: {
                id: expense.category.id,
                name: expense.category.name
            },
            reimbursable: expense.reimbursable,
            amount: {
                value: expense.amount.value,
                currency: {
                    id: expense.amount.currency.id,
                    country: expense.amount.currency.country,
                    country_code: expense.amount.currency.country_code,
                    symbol: expense.amount.currency.symbol
                }
            },
            custom_fields: []
        }
        custom_fields&.each do |field|
          if field and field.field_configuration.present?
            data[:custom_fields] << {
                id: field.field_configuration.id,
                label: field.field_configuration.field_name,
                value: field.value&.value
            }
          end
        end
      elsif extracted_data.present?
        category = Category.find_by(id: extracted_data.category_id)
        currency = Currency.find_by(id: extracted_data.currency_id)
        data = {
            id: nil,
            merchant: extracted_data.merchant,
            date: DateUtils.date_formatted(extracted_data.datetime),
            # note: extracted_data.note,
            note: nil,
            category: {
                id: category&.id,
                name: category&.name
            },
            reimbursable: true,
            amount: {
                value: extracted_data.amount_value,
                currency: {
                    id: currency&.id,
                    country: currency&.country,
                    country_code: currency&.country_code,
                    symbol: currency&.symbol
                }
            },
            custom_fields: []
        }
      end
      data
    end

  end

end
