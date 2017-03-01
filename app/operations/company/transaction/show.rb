class Company::Transaction::Show < Company::Base
  attr_accessor :start_date, :end_date, :last_transaction_date, :last_transaction, :required_transactions

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

    if self.end_date.blank?
      self.end_date = Date.today
    end

    if start_date.blank?
      self.start_date = self.end_date - 1
    end

    if company.company_transactions.present?
      self.last_transaction = company.company_transactions.last
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

  def process
    # Update the table with all new statements
    if last_transaction_date < end_date
      response = ItzCash::CompanyCreditStatementByDate.(company, start_date: start_date, end_date: end_date)
      unless response.success?
        add_message :error, response.messages[:error]
        return
      end
      transactions = response.transactions
      transactions.each do |t|
        company.company_transactions.create request_id: t[:request_id], merchant_name: t[:merchant_name],
                                            transaction_date: t[:transaction_date],
                                            transaction_amount_attributes: {value: t[:transaction_amount], currency_id: 1},
                                            transaction_type: t[:transaction_type],
                                            transaction_id: t[:transaction_id],
                                            balance_amount_attributes: {value: t[:balance], currency_id: 1}
      end
    end
    self.required_transactions = company.company_transactions.with_date_range(start_date, end_date)
  end

  def success
    Company::Transaction::Show::SuccessPresenter.(company, transactions: self.required_transactions)
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