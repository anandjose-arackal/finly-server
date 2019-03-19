class IciciBankApi::TransactionInitiate < IciciBankApi::Base

  attr_accessor :payment, :icici_bank_transaction, :transfer_request

  def initialize(params)
    self.transfer_request = params[:transfer_request]
    self.payment = params[:payment]
    self.params = {}
  end

  def self.call(transfer_request)
    self.new(transfer_request).run
  end

  def pre_validate
    if transfer_request.blank?
      add_message :error, "Invalid parameters"
      return
    end

    unless transfer_request.class.name == "IciciBankTransferRequest"
      add_message :error, "Invalid parameters"
    end

    unless transfer_request.valid?
      add_message :error, transfer_request.errors
      return
    end
  end

  def init
    self.company = self.payment.company
    super # so that the variables are initialized from the config file
    self.icici_bank_transaction = self.payment.reference_resource
    self.receiving_account = self.icici_bank_transaction.receiving_account
  end

  def icici_bank_action
    'icici_bank_transaction_initiate'
  end

  def raw_api_params
    {
        AGGRID: self.company_details[:AGGR_ID],
        AGGRNAME: self.company_details[:AGGR_NAME],
        CORPID: self.company_details[:CORP_ID],
        USERID: self.company_details[:USER_ID],
        URN: self.company.icici_bank_config.urn,
        UNIQUEID: self.transfer_request.unique_request_number,
        DEBITACC: self.company_details[:DEBIT_ACC_NO],
        CREDITACC: self.receiving_account.account_number,
        IFSC: self.receiving_account.ifsc,
        AMOUNT: self.icici_bank_transaction.amount.value,
        CURRENCY: self.icici_bank_transaction.amount.currency.country_code,
        TXNTYPE: self.icici_bank_transaction.transfer_type,
        PAYEENAME: self.receiving_account.account_owner.name,
        REMARKS: self.payment.note,
        CUSTOMERINDUCED: "N"
    }
  end

  def post_params
    encrypt_params(
        raw_api_params
    )
  end

  def parse

  end

  def post_process
    case self.response.status
      when 404

      when 500

      when 200
        self.parsed_response = JSON.parse(self.response.body)

    end
  end

  def success?
    self.bank_transaction.completed? || self.bank_transaction.processing?
  end

  def failure?
    self.bank_transaction.failed? || self.bank_transaction.possible_failure?
  end

  def success
    params[:bank_transaction] = self.bank_transaction
    params[:transfer_request] = self.transfer_request
    IciciBankApi::TransactionInitiate::TransactionSuccessPresenter.new(params, messages)
  end

  def failure
    params[:bank_transaction] = self.bank_transaction
    params[:transfer_request] = self.transfer_request
    IciciBankApi::TransactionInitiate::TransactionFailurePresenter.new(params, messages)
  end

  class IciciBankApi::TransactionInitiate::TransactionSuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :transfer_request, :bank_transaction

    def initialize(params, messages)
      self.messages = messages
      self.transfer_request = params[:transfer_request]
      self.bank_transaction = params[:bank_transaction]
    end
  end

  class IciciBankApi::TransactionInitiate::TransactionFailurePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :transfer_request, :bank_transaction

    def initialize(params, messages)
      self.messages = messages
      self.transfer_request = params[:transfer_request]
      self.bank_transaction = params[:bank_transaction]
    end
  end

end