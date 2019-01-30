class YesBankApi::Transfer::BankTransfer < YesBankApi::Base

  attr_accessor :account_number, :transaction_result, :error_message, :transfer_request,
                :error_code, :transfer_status_id, :company, :bank_transaction, :payment,
                :account, :beneficiary_mobile_number, :beneficiary_email

  # in this context, success would imply one of these transactions
  SUCCESS_RESPONSE_CODES = ["COMPLETED", "SENT_TO_BENEFICIARY", "IN_PROCESS", "SCHEDULED_FOR_NEXT_WORKDAY"]

  def initialize(params)
    self.transfer_request = params[:transfer_request]
    self.payment = params[:payment]
    self.params = {}
  end

  def self.call(transfer_request)
    self.new(transfer_request).run
  end

  # defines the respective action that this API handler is executing
  def yes_bank_action
    'transfer'
  end

  def file_logger_base_params
    request = self.transfer_request.as_json
    request[:action] = 'bank_transfer'
    request
  end

  def pre_validate
    if transfer_request.blank?
      add_message :error, "Invalid parameters"
      return
    end

    unless transfer_request.class.name == "TransferRequest"
      add_message :error, "Invalid parameters"
    end

    unless transfer_request.valid?
      add_message :error, transfer_request.errors
      return
    end
  end

  def init
    self.company_id = self.payment.payment_order.company_id
    super()
    self.account = payment.receiving_account
    # extracting contact email and mobile number
    self.beneficiary_email = self.account.account_owner.email
    self.beneficiary_mobile_number = self.account.account_owner.mobile_number
    set_xml_params
  end

  def parse
    # self.parsed_response = Hash.from_xml(response.body)
  end


  def post_process
    # handle the various error cases here
    # case 200
    case self.response.status
      when 404
        add_message :error, "The service is temporarily down. Please try again later"
        self.transfer_status_id = BankTransferStatus.id_for(:failed)
      when 401
        add_message :error, "Unauthorized. Please check the credentials being used for the API"
        self.transfer_status_id = BankTransferStatus.id_for(:failed)
      when 500
        self.parsed_response = Hash.from_xml(response.body)
        ap parsed_response
        self.error_code = parsed_response["Envelope"]&.dig("Body")&.dig("Fault")&.dig("Code")&.dig("Subcode")&.dig("Value")
        # if the transfer failed, we will see it the error message here, else it'll be nil
        self.transfer_request.bank_error_message = parsed_response["Envelope"]&.dig("Body")&.dig("Fault")&.dig("Reason")&.dig("Text")
        case self.error_code
          # potential failure cases
          when "ns:E504", "ns:502", "ns:E500"
            self.transfer_status_id = BankTransferStatus.id_for(:possible_failure)
            Event::EAlert::Create.(nil, title: 'E:504 - Timeout error',description: "Errors: Timout error - check sideki logs. <br><br> #{payment.as_json}", subject: 'Finly Vendor Payments - E:504')
          # definite failure case
          when "ns:E406", "ns:E6001", "ns:E6002", "ns:E6003", "ns:E8000", "ns:E1001", "ns:E1002", "ns:E1003", "ns:E1004", "ns:E1028", "flex:E18", "flex:E307",
            "flex:E404", "flex:E449", "flex:E8036", "flex:E8087", "flex:E9072", "npci:E08", "npci:EM1", "npci:EM2", "npci:EM3", "npci:EM4", "npci:EM5", "npci:E307",
            "npci:E449", "atom:E307", "atom:E404", "atom:E449", "sfms:E99", "sfms:E70", "sfms:E18", "ns:E9001", "ns:E9002", "ns:E400"
            self.transfer_status_id = BankTransferStatus.id_for(:failed)
          when "ns:E429", "nsE402", "ns:E410", "ns:E403"
            # have to trigger a mailer or something - either transaction limit reached, or not enough balance or something on those lines
            self.transfer_status_id = BankTransferStatus.id_for(:failed)
          else
            self.transfer_status_id = BankTransferStatus.id_for(:failed)
        end
      when 200
        self.parsed_response = Hash.from_xml(response.body)
        ap parsed_response
        # if the below is nil, i.e. the transaction most likely failed, the transaction result won't be either of the success ones
        self.transfer_request.transaction_result = parsed_response["Envelope"]&.dig("Body")&.dig("transferResponse")&.dig("transactionStatus")&.dig("statusCode")
        self.transfer_request.bank_reference_number = parsed_response["Envelope"]&.dig("Body")&.dig("transferResponse")&.dig("transactionStatus")&.dig("bankReferenceNo")
        if self.transfer_request.bank_reference_number.present?
          if Constants::YesBank::SUCCESSFUL_TRANSACTION_STATUSES.include?(self.transfer_request.transaction_result)
            self.transfer_status_id = BankTransferStatus.id_for(:completed)
          elsif Constants::YesBank::PROCESSING_TRANSACTION_STATUSES.include?(self.transfer_request.transaction_result)
            self.transfer_status_id = BankTransferStatus.id_for(:processing)
          end
        end
      else
        # do nothing?
    end
    # create the bank transaction right here
    self.company = Company.find_by(id: self.transfer_request.company_id)
    if self.payment&.reference_resource&.is_a?(BankTransaction)
      # just update the bank transaction with the latest details
      self.bank_transaction = payment.reference_resource
      self.bank_transaction.update(
                          bank_reference_number: self.transfer_request.bank_reference_number,
                          transfer_status_id: self.transfer_status_id,
                          bank_response: self.transfer_request.transaction_result
      )
      self.payment.retry_count += 1
    else
      # this is an anomaly, so send email and flag it
      Event::EAlert::Create.(nil, title: 'Payment did not have an associated bank transaction', description: "The payment: #{self.payment} inside the API Handler did not have an associated bank transaction.", subject: 'Payment did not have an associated bank transaction')
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
    YesBankApi::Transfer::BankTransfer::TransactionSuccessPresenter.new(params)
  end

  def failure
    params[:bank_transaction] = self.bank_transaction
    params[:transfer_request] = self.transfer_request
    YesBankApi::Transfer::BankTransfer::TransactionFailurePresenter.new(params)
  end

  class YesBankApi::Transfer::BankTransfer::TransactionSuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :transfer_request, :bank_transaction

    def initialize(params)
      self.transfer_request = params[:transfer_request]
      self.bank_transaction = params[:bank_transaction]
    end
  end

  class YesBankApi::Transfer::BankTransfer::TransactionFailurePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :transfer_request, :bank_transaction

    def initialize(params)
      self.transfer_request = params[:transfer_request]
      self.bank_transaction = params[:bank_transaction]
    end
  end

  private

  def set_xml_params
    liquid_template = load_soap_template
    # sanitizing beneficiary name before request
    beneficiary_name = transfer_request.beneficiary_name
    # ILLEGAL_CHARACTERS.each do |character|
    #   beneficiary_name = beneficiary_name.sub(character, '')
    # end
    beneficiary_name = beneficiary_name.gsub(/[^0-9A-Za-z]/, '')
    beneficiary_name = beneficiary_name[0..30]&.strip

    beneficiary_ifsc = transfer_request.ifsc&.match(Constants::VALID_IFSC).to_s rescue ""
    self.template = liquid_template.render(
        'UNIQUE_REFERENCE_NUMBER' => transfer_request.generate_unique_reference,
        'APP_ID' => application_id,
        'CUSTOMER_ID' => customer_id,
        'ACCOUNT_NUMBER' => account_number,
        'BENEFICIARY_NAME' => beneficiary_name,
        'BENEFICIARY_ACCOUNT_NUMBER' => transfer_request.beneficiary_account_number&.strip,
        'BENEFICIARY_IFSC' => beneficiary_ifsc,
        'TRANSFER_TYPE' => transfer_request.transfer_type&.strip&.upcase,
        'TRANSFER_CURRENCY_CODE' => transfer_request.transfer_currency_code,
        'TRANSFER_AMOUNT' => transfer_request.transfer_amount,
        'BENEFICIARY_EMAIL' => (self.beneficiary_email.present? ? (self.beneficiary_email) : ("noreply@finly.io")),
        'BENEFICIARY_MOBILE_NUMBER' => (self.beneficiary_mobile_number.present? ? (self.beneficiary_mobile_number) : ("7975520468"))
    )
  end

  def generated_reference_number
    transfer_request.unique_reference_number
  end

  def set_response_parameters
    self.transfer_request.transaction_result = transaction_result
    self.transfer_request.bank_reference_number = parsed_response["Envelope"]&.dig("Body")&.dig("transferResponse")&.dig("transactionStatus")&.dig("bankReferenceNo")
  end
end