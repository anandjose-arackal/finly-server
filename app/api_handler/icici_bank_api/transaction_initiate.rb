class IciciBankApi::TransactionInitiate < IciciBankApi::Base

  attr_accessor :payment, :icici_bank_transaction, :transfer_request, :receiving_account

  def initialize(params)
    self.transfer_request = params[:transfer_request]
    self.payment = params[:payment]
    self.icici_bank_transaction = params[:bank_transaction]
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
      return
    end

    unless transfer_request.valid?
      add_message :error, transfer_request.errors
      return
    end

    unless self.icici_bank_transaction.present?
      add_message :error, "Bank transaction not present"
      return
    end
  end

  def init
    self.company = self.payment.payment_order.company
    # self.company = Company.second
    super # so that the variables are initialized from the config file
    self.receiving_account = self.payment.receiving_account
    super()
  end

  def env_key
    'icici_bank_transaction_initiate'
  end

  def raw_api_params
    remarks = self.payment.note.blank? ? "Null" : self.payment.note
    remarks = remarks.gsub(/[^0-9A-Za-z]/, '') # this is to remove all special characters from the remarks attribute
    # additionally if this is a NEFT transactions we have to further truncate the narration to 31 characters
    if self.payment.neft?
      remarks = remarks[0..30]
    end

    # payee_name will always be the bank account's name henceforth
    payee_name = self.receiving_account&.name

    # if self.receiving_account&.account_owner.is_a?(YesBankVendor)
    #   payee_name = self.receiving_account.account_owner.business_name
    # else
    #   payee_name = self.receiving_account.account_owner.name
    # end

    {
        AGGRID: self.company_details["AGGR_ID"],
        AGGRNAME: self.company_details["AGGR_NAME"],
        CORPID: self.company_details["CORP_ID"],
        USERID: self.company_details["USER_ID"],
        URN: self.company.icici_bank_config.urn,
        UNIQUEID: self.icici_bank_transaction.unique_request_number.to_s,
        DEBITACC: self.company_details["DEBIT_ACC_NO"],
        CREDITACC: self.receiving_account.account_number,
        # CREDITACC: "000405002777",
        IFSC: retrieve_ifsc,
        # IFSC: "DLXB0000092",
        # IFSC: "ICIC0000011",
        AMOUNT: self.icici_bank_transaction.amount.value.to_f.to_s,
        # AMOUNT: "200",
        CURRENCY: self.icici_bank_transaction.amount.currency.country_code,
        # CURRENCY: "INR",
        # TXNTYPE: "OWN",
        TXNTYPE: retrieve_transaction_type,
        # TXNTYPE: "OWN", # "RTG", "RGS"
        PAYEENAME: payee_name,
        # PAYEENAME: "Sreeram",
        REMARKS: remarks.to_s,
        # REMARKS: "This is a test note",
        CUSTOMERINDUCED: "N"
    }
  end

  def post_params
    encrypt_params(
        raw_api_params
    )
  end

  def post_process
    case self.response&.status
      when 404
        self.icici_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:possible_failure))
        add_message :error, "Service temporarily unavailable"
        self.transfer_request.bank_error_message = "Service temporarily unavailable"
      when 500
        self.icici_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:possible_failure))
        add_message :error, "Service temporarily unavailable"
        self.transfer_request.bank_error_message = "Service temporarily unavailable"
      when 200
        # mark the transaction as processing.
        # log the parsed params so that we can get visibility on the transaction

        if self.parsed_response["RESPONSE"] == "SUCCESS" || self.parsed_response["Response"] == "SUCCESS"
          case self.parsed_response["STATUS"]
            when "PENDING FOR PROCESSING"
              self.icici_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:pending_for_processing))
            when "SUCCESS"
              utr = self.parsed_response["UTRNUMBER"]
              self.icici_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:pending_utr),
                                                 utr: utr)
            when "FAILURE"
              self.icici_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:failed))
              error_message = self.parsed_response["Message"]
              add_message :error, error_message
              self.transfer_request.bank_error_message = error_message
            else
              # handle it gracefully
          end
        elsif self.parsed_response["RESPONSE"] == "FAILURE" || self.parsed_response["Response"] == "FAILURE"
          self.icici_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:failed))
          error_message = self.parsed_response["MESSAGE"] || self.parsed_response["Message"]
          add_message :error, error_message
          self.transfer_request.bank_error_message = error_message
        else
          # any other case must be a failure as well
          self.icici_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:possible_failure))
          error_message = self.parsed_response["MESSAGE"] || self.parsed_response["Message"] || self.parsed_response["message"]
          add_message :error, error_message
          self.transfer_request.bank_error_message = error_message
        end
    else
      # do nothing?
    end
  end

  def success?
    self.icici_bank_transaction.pending_utr? || self.icici_bank_transaction.pending_for_processing?
  end

  def failure?
    self.icici_bank_transaction.failed? || self.icici_bank_transaction.possible_failure?
  end

  def success
    params[:bank_transaction] = self.icici_bank_transaction
    params[:transfer_request] = self.transfer_request
    IciciBankApi::TransactionInitiate::TransactionSuccessPresenter.new(params, messages)
  end

  def failure
    params[:bank_transaction] = self.icici_bank_transaction
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

  private

  def retrieve_ifsc
    if self.icici_bank_transaction.receiving_account&.ifsc.to_s.include?("ICIC")
      return "ICIC0000011"
    end
    return self.icici_bank_transaction.receiving_account&.ifsc
  end

  def retrieve_transaction_type
    if self.icici_bank_transaction.receiving_account&.ifsc.to_s.include?("ICIC")
      return "TPA"
    end
    return self.icici_bank_transaction.transfer_type
  end

end