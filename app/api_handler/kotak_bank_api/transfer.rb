class KotakBankApi::Transfer < KotakBankApi::Base

  attr_accessor :account_number, :transaction_result, :error_message, :transfer_request,
                :error_code, :transfer_status_id, :company, :bank_transaction, :payment,
                :account, :beneficiary_mobile_number, :beneficiary_email

  def initialize(params)
    self.transfer_request = params[:transfer_request]
    self.payment = params[:payment]
    self.bank_transaction = params[:bank_transaction]
    self.params = {}
  end

  def self.call(transfer_request)
    self.new(transfer_request).run
  end

  # defines the respective action that this API handler is executing
  def bank_action
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

    unless transfer_request.class.name == "KotakBankTransferRequest"
      add_message :error, "Invalid parameters"
      return
    end

    unless transfer_request.valid?
      add_message :error, transfer_request.errors
      return
    end
  end

  def init
    self.company_id = self.payment&.payment_order&.company_id || self.bank_transaction.company_id
    super()
    self.account = payment&.receiving_account
    # extracting contact email and mobile number
    unless self.account&.account_owner&.is_a?(Company)
      self.beneficiary_email = self.account&.account_owner&.email
      self.beneficiary_mobile_number = self.account&.account_owner&.mobile_number
    end
    set_xml_params
  end

  def parse
    # self.parsed_response = Hash.from_xml(response.body)
  end


  def post_process
    # handle the various error cases here
    # case 500
    case self.response.status
    when 400
      add_message :error, "Invalid API Key"
      self.transfer_status_id = BankTransferStatus.id_for(:failed)
    when 403
      add_message :error, "Schema Validation Error"
      self.transfer_status_id = BankTransferStatus.id_for(:failed)
    when 404
      add_message :error, "The service is temporarily down. Please try again later"
      self.transfer_status_id = BankTransferStatus.id_for(:failed)
    when 401
      add_message :error, "Unauthorized."
      self.transfer_status_id = BankTransferStatus.id_for(:failed)
    when 500
      self.parsed_response = Hash.from_xml(response.body)
    when 200
      self.parsed_response = Hash.from_xml(response.body)

      ap parsed_response
      # if the below is nil, i.e. the transaction most likely failed, the transaction result won't be either of the success ones
      acknowledgement = parsed_response["Envelope"]&.dig("Body")&.dig("Payment")&.dig("AckHeader")

      status_code = acknowledgement["StatusCd"]

      if status_code.present?
        case status_code
        when "000"
          # Success | All Instruments accepted Successfully
          self.transfer_request.response_status_code = status_code
          self.transfer_status_id = BankTransferStatus.id_for(:completed)
          self.transfer_request.transaction_result = acknowledgement["StatusRem"]
        when "001"
          # Error | XML Schema validation failed
          self.transfer_request.response_status_code = status_code
          self.transfer_status_id = BankTransferStatus.id_for(:failed)
          self.transfer_request.transaction_result = acknowledgement["StatusRem"]
        when "002"
          # Error | Duplicate Message Id
          # Should ideally reinitiate the transaction
          self.transfer_request.response_status_code = status_code
          self.transfer_status_id = BankTransferStatus.id_for(:failed)
          self.transfer_request.transaction_result = acknowledgement["StatusRem"]
        when "003"
          # Error | Invalid Client Code
          self.transfer_status_id = BankTransferStatus.id_for(:failed)
          self.transfer_request.response_status_code = status_code
          self.transfer_request.transaction_result = acknowledgement["StatusRem"]
        when "004"
          # Error | Duplicate Instrument Ref Number within Request
          self.transfer_status_id = BankTransferStatus.id_for(:failed)
          self.transfer_request.response_status_code = status_code
          self.transfer_request.transaction_result = acknowledgement["StatusRem"]
        when "005"
          # todo - kotak (Check what this means)
          # Mostly when multiple payments are sent in one request and few of the requests were accepted
          # Error | Request Partially Accepted
          self.transfer_request.response_status_code = status_code
          self.transfer_status_id = BankTransferStatus.id_for(:failed)
          self.transfer_request.transaction_result = acknowledgement["StatusRem"]
        when "006"
          # Error | Instrument rejected due to data validation failure
          self.transfer_request.response_status_code = status_code
          self.transfer_status_id = BankTransferStatus.id_for(:failed)
          self.transfer_request.transaction_result = acknowledgement["StatusRem"]
        when "007"
          # todo - kotak (Check what this means)
          # Error | Instrument validated successfully
          self.transfer_request.response_status_code = status_code
          self.transfer_status_id = BankTransferStatus.id_for(:failed)
          self.transfer_request.transaction_result = acknowledgement["StatusRem"]
        when "008"
          # Error | Invalid Web service consumer IP address
          self.transfer_request.response_status_code = status_code
          self.transfer_status_id = BankTransferStatus.id_for(:failed)
          self.transfer_request.transaction_result = acknowledgement["StatusRem"]
        when "009"
          # Error | All Instruments rejected due to data validation failure
          self.transfer_request.response_status_code = status_code
          self.transfer_status_id = BankTransferStatus.id_for(:failed)
          self.transfer_request.transaction_result = acknowledgement["StatusRem"]
        when "010"
          # Error | Default user not found for given client
          self.transfer_request.response_status_code = status_code
          self.transfer_status_id = BankTransferStatus.id_for(:failed)
          self.transfer_request.transaction_result = acknowledgement["StatusRem"]
        when "011"
          # Error | System encountered severe error. Please contact admin
          self.transfer_request.response_status_code = status_code
          self.transfer_status_id = BankTransferStatus.id_for(:failed)
          self.transfer_request.transaction_result = acknowledgement["StatusRem"]
        end
      else
        # Did not get expected response
        add_message :error, "Unknown Response"
        self.transfer_status_id = BankTransferStatus.id_for(:failed)
      end


    else
        # do nothing?
    end
    # create the bank transaction right here
    #
    self.company = Company.find_by(id: self.transfer_request.company_id)
    if self.payment&.reference_resource&.is_a?(KotakBankTransaction) || self.bank_transaction.present?
      # just update the bank transaction with the latest details
      self.bank_transaction = self.bank_transaction || payment.reference_resource
      # UTR is never updated here, as Kotak Bank Payment api never returns UTR
      self.bank_transaction.update(
                          transfer_status_id: self.transfer_status_id,
                          response_status_code: self.transfer_request.response_status_code,
                          bank_response: self.transfer_request.transaction_result,
                          beneficiary_name: self.transfer_request.beneficiary_name
      )
      self.payment&.update(retry_count: self.payment.retry_count.to_f + 1)
    else
      # this is an anomaly, so send email and flag it
      Event::EAlert::Create.(nil, title: 'Payment did not have an associated bank transaction', description: "The payment: #{self.payment.to_json} inside the API Handler did not have an associated bank transaction.", subject: 'Payment did not have an associated bank transaction')
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
    KotakBankApi::Transfer::TransactionSuccessPresenter.new(params, messages)
  end

  def failure
    params[:bank_transaction] = self.bank_transaction
    params[:transfer_request] = self.transfer_request
    KotakBankApi::Transfer::TransactionFailurePresenter.new(params, messages)
  end

  class KotakBankApi::Transfer::TransactionSuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :transfer_request, :bank_transaction

    def initialize(params, messages)
      self.messages = messages
      self.transfer_request = params[:transfer_request]
      self.bank_transaction = params[:bank_transaction]
    end
  end

  class KotakBankApi::Transfer::TransactionFailurePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :transfer_request, :bank_transaction

    def initialize(params, messages)
      self.messages = messages
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
        'UNIQUE_REFERENCE_NUMBER' => transfer_request.unique_reference_number,
        'MESSAGE_SOURCE' => 'FINLY',
        'CLIENT_CODE' => "#{self.configuration['CLIENT_CODE']}",
        # 'APP_ID' => application_id,
        # 'CUSTOMER_ID' => customer_id,
        'ACCOUNT_NUMBER' => account_number,
        'PRODUCT_CODE' => "#{self.configuration['PRODUCT_CODE']}",
        'BENEFICIARY_NAME' => beneficiary_name,
        'BENEFICIARY_ACCOUNT_NUMBER' => transfer_request.beneficiary_account_number&.strip,
        'BENEFICIARY_IFSC' => beneficiary_ifsc,
        'DESCRIPTION' => "#{beneficiary_name} - #{payment&.id}",
        # 'TRANSFER_TYPE' => transfer_request.transfer_type&.strip&.upcase,
        'TRANSFER_TYPE' => resolve_transfer_type(beneficiary_ifsc, transfer_request.transfer_type),
        'TRANSFER_CURRENCY_CODE' => transfer_request.transfer_currency_code,
        'TRANSFER_AMOUNT' => transfer_request.transfer_amount,
        'BENEFICIARY_EMAIL' => (self.beneficiary_email.present? ? (self.beneficiary_email) : ("noreply@finly.io")),
        'BENEFICIARY_MOBILE_NUMBER' => (self.beneficiary_mobile_number.present? ? (self.beneficiary_mobile_number) : ("7975520468")),
        'PAYMENT_DATE' => Date.today.strftime()
    )
  end

  def generated_reference_number
    transfer_request.unique_reference_number
  end

  def set_response_parameters
    self.transfer_request.transaction_result = transaction_result
    self.transfer_request.bank_reference_number = parsed_response["Envelope"]&.dig("Body")&.dig("transferResponse")&.dig("transactionStatus")&.dig("bankReferenceNo")
  end

  def resolve_transfer_type(ifsc, transfer_type)
    if ifsc.present? && ifsc[0..3] == "KKBK"
      ""
    else
      transfer_type&.strip&.upcase
    end
  end
end