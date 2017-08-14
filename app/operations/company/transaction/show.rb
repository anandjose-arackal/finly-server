#
# Params -> start_date(DateTime object), end_date(DateTime Object)
# Query is date >= start_date && date <= end_date
#

class Company::Transaction::Show < Company::Base
  attr_accessor :start_date, :end_date, :last_transaction_date, :last_transaction, :required_transactions, :transactions

  def self.call(company, params={})
    self.new(company, params).run
  end

  def initialize(company, params={})
    self.company = company
    super(nil, params)
  end

  def pre_validate
    if company.blank?
      add_message :error, 'Company not found'
      return
    end
    return if params.blank?
    if params[:start_date].present? and not (params[:start_date].kind_of?(Date) or params[:start_date].kind_of?(DateTime))
      add_message :error, 'Start Date is not a date object'
      return
    end
    if params[:end_date].present? and not (params[:end_date].kind_of?(Date) or params[:end_date].kind_of?(DateTime))
      add_message :error, 'End Date is not a date object'
      return
    end
  end

  def init
    if params.present?
      self.end_date = params[:end_date]
      self.start_date = params[:start_date]
    end

    # If end date is not defined, set current date as end date
    if self.end_date.blank?
      self.end_date = DateTime.now
    end

    # If start date is not defined, set the end date as starting date
    if start_date.blank?
      self.start_date = self.end_date
    end

    # If the no transactions are recorded for the company, to ensure we have all transactions we set the starting date as the day company was created
    # If company transactions are defined, fetch all transaction from the last date the transaction was recorded
    if company.company_transactions.present?
      self.last_transaction = company.company_transactions.sort_date(:asc).last
      self.last_transaction_date = last_transaction.transaction_date
    else
      self.last_transaction_date = company.created_at
    end
  end

  def authorize
    if self.start_date.blank? or self.end_date.blank? or self.last_transaction_date.blank?
      add_message :error, 'Error loading configuration'
    end
  end

  def validate
    if self.start_date > self.end_date
      add_message :error, 'Starting date cannot be after end date'
    end
  end

  def process
    # Update the table with all new statements. To ensure we do not miss out on any transaction we query all
    # transactions for (last_transaction_date - 1), all duplicate transactions will anyway be discarded.
    # todo if date difference is exceeding 20, split in sizes of 20s
    response = ItzCash::CompanyCreditStatementByDate.(company, start_date: last_transaction_date - 1, end_date: Date.today + 1)
    unless response.success?
      add_message :error, response.messages[:error]
      return
    end
    transactions = response.transactions
    new_company_transactions = []
    # Store all company transactions. All duplicate transactions will not be fetched
    transactions.each do |t|
      company_transaction = company.company_transactions.create request_id: t[:request_id], merchant_name: t[:merchant_name],
                                                                transaction_date: DateUtils.datetime_in_ist(t[:transaction_date]),
                                                                transaction_amount_attributes: {value: t[:transaction_amount], currency_id: 1},
                                                                transaction_type: t[:transaction_type],
                                                                transaction_id: t[:transaction_id],
                                                                balance_amount_attributes: {value: t[:balance], currency_id: 1},
                                                                transaction_mode: t[:transaction_mode],
                                                                merchant_type_key: t[:merchant_type_key]
      if company_transaction.valid?
        new_company_transactions << company_transaction
      end
    end
    # Create Finly Transactions from all newly created transactions
    create_finly_transactions new_company_transactions

    self.required_transactions = company.company_transactions.with_date_range(start_date.beginning_of_day, end_date.end_of_day)
  end

  def create_finly_transactions(transactions)
    transactions&.each do |company_transaction|
      # Ignore card transfers are these transactions would be generated from payments
      next if company_transaction.card_transfer?
      transaction_type = TransactionType.id_for(company_transaction.transaction_type.downcase)
      reference_id = Generator.reference_id_for(company.itz_cash_company_account, nil, nil, company_transaction.transaction_date)
      if company_transaction.transaction_type.downcase == 'debit'
        purpose_id = PaymentPurpose.id_for(:advance)
      else
        if company_transaction.merchant_name.downcase.include?('manual') || company_transaction.merchant_name.downcase.include?('payu')
          purpose_id = PaymentPurpose.id_for(:corporate_balance_load)
        else
          purpose_id = PaymentPurpose.id_for(:balance_clearance)
        end
      end
      params = {
          transaction_type_id: transaction_type,
          amount_attributes: {
              value: company_transaction.transaction_amount.value,
              currency_id: Currency.id_for(:INR)
          },
          transaction_reference_id: reference_id,
          status_id: TransactionStatus.id_for(:success),
          payment_purpose_id: purpose_id,
          opening_balance: nil,
          closing_balance: nil,
          associated_transaction: company_transaction,
          payment: nil,
          company_id: company.id,
          date: company_transaction.transaction_date
      }
      transaction = company.itz_cash_company_account.finly_transactions.create(params)
      unless transaction.valid?
        raise "#{transaction.errors.full_messages}"
      end
    end
  end

  def success
    Company::Transaction::Show::SuccessPresenter.new(company, transactions: self.required_transactions)
  end

  class Company::Transaction::Show::SuccessPresenter < Company::Base::CompanyPresenter
    attr_accessor :transactions

    def initialize(company, params)
      super(nil, params)
      self.company = company
    end

    def init
      self.transactions = params[:transactions]
    end

  end

end