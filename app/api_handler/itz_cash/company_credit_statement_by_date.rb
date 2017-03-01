# params = {start_date, end_date}
class ItzCash::CompanyCreditStatementByDate < ItzCash::Base
  attr_accessor :start_date, :end_date, :company

  def initialize(company, params={})
    self.company = company
    super(nil, params)
  end

  def pre_validate
    if company.blank?
      add_message :error, 'Company not found'
      return
    end
    if params.blank? or params[:start_date].blank? or (not params[:start_date].kind_of?(Date) and
        not params[:start_date].kind_of?(DateTime) and not params[:start_date].kind_of?(ActiveSupport::TimeWithZone))
      add_message :error, 'Error in request. Please try again'
      return
    end
    if params.blank? or params[:end_date].blank? or (not params[:end_date].kind_of?(Date) and not params[:end_date].kind_of?(DateTime) and
        not params[:end_date].kind_of?(ActiveSupport::TimeWithZone))
      add_message :error, 'Error in request. Please try again'
      return
    end
    if company.d_code.blank?
      add_message :error, 'Company has not been configured to initiate the transfer'
    end
  end

  def env_key
    'itzcash_company_statement_by_date'
  end

  def post_params
    itzmodule = Constants::ItzCash::MODULE
    dcode = company.d_code
    easy_account_no = company.easy_account_no

    # ItzCash queries for all transactions -> date > start_date && date <= end_date
    {dcode: dcode, easyaccountno: easy_account_no, itzmodule: itzmodule, startdate: start_date, enddate: end_date}
  end

  def init
    super
    if self.company.easy_account_no.blank?
      response = ItzCash::VirtualAccountBalance.(company)

      unless response.success?
        add_message :error, response.messages[:error]
        return
      end

      if response.company.itz_cash_property.easy_account_no.blank? or response.company.itz_cash_property.easy_account_no.blank?
        company.itz_cash_property.easy_account_no = response.wallets.first[:account_number]
        company.save
      end
    end
    self.start_date = params[:start_date].strftime("%d%m%Y")
    self.end_date = params[:end_date].strftime("%d%m%Y")
  end

  def validate
    if self.company.d_code.blank? or self.company.easy_account_no.blank?
      add_message :error, 'Error loading configuration'
      return
    end
    if self.start_date.blank? or self.end_date.blank?
      add_message :error, 'Error loading configuration'
    end
  end

  def success
    params[:response_code] = parsed_response[0]
    params[:transactions] = []
    description = parsed_response[1]
    if description.size > 1
      # All transactions are delimited by '|'
      transactions = description.split('|')
      transactions.each do |transaction_string|
        # All fields within a transactions are delimited by '$'
        transaction = transaction_string.split('$')
        if transaction.present?
          request_id = transaction[0].squish
          merchant_name = transaction[1].squish
          transaction_date = transaction[2].squish
          transaction_amount = transaction[3].squish.to_d
          transaction_type = transaction[4].squish
          transaction_id = transaction[5].squish
          balance = transaction[6].squish.to_d
          size =  params[:transactions].size
          params[:transactions][size] = {request_id: request_id,
                                        merchant_name: merchant_name,
                                        transaction_date: transaction_date,
                                        transaction_amount: transaction_amount,
                                        transaction_type: transaction_type,
                                        transaction_id: transaction_id,
                                        balance: balance}
        end
      end
    end

    ItzCash::CompanyCreditStatementByDate::SuccessPresenter.new(self.user, params, messages)
  end

  class ItzCash::CompanyCreditStatementByDate::SuccessPresenter < BaseHandler::BasePresenter::SuccessPresenter
    attr_accessor :response_code, :transactions

    def init
      self.response_code = params[:response_code]
      self.transactions = params[:transactions]
    end

  end

end