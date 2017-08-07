class YesBank::Transfer::BankTransfer < YesBank::Base

  attr_accessor :account_number, :transaction_result, :error_message, :transfer_request

  SUCCESS_RESPONSE_CODES = ["COMPLETED", "SENT_TO_BENEFICIARY", "IN_PROCESS", "SCHEDULED_FOR_NEXT_WORKDAY"]

  def initialize(transfer_request)
    self.transfer_request = transfer_request
    self.params = {}
  end

  def self.call(transfer_request)
    self.new(transfer_request).run
  end

  # defines the respective action that this API handler is executing
  def yes_bank_action
    'transfer'
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
    super()
    self.account_number = YAML.load_file(config_path)[Rails.env]['account_number']
    set_xml_params
  end

  def parse
    self.parsed_response = Hash.from_xml(response.body)
  end

  def success?
    ap parsed_response
    unless SUCCESS_RESPONSE_CODES.include?(transfer_request.transaction_result)
      false
    end
    true
  end

  def post_process
    self.parsed_response = Hash.from_xml(response.body)
    # if the below is nil, i.e. the transaction most likely failed, the transaction result won't be either of the success ones
    self.transfer_request.transaction_result = parsed_response["Envelope"]&.dig("Body")&.dig("transferResponse")&.dig("transactionStatus")&.dig("statusCode")
    # if the transfer failed, we will see it the error message here, else it'll be nil
    self.transfer_request.bank_error_message = parsed_response["Envelope"]&.dig("Body")&.dig("Fault")&.dig("Reason")&.dig("Text")
  end

  def failure?
    if transfer_request.bank_error_message.present?
      return true
    end
  end

  def success
    YesBank::Transfer::BankTransfer::TransactionSuccessPresenter.new(transfer_request)
  end

  def failure
    YesBank::Transfer::BankTransfer::TransactionFailurePresenter.new(transfer_request)
  end

  class YesBank::Transfer::BankTransfer::TransactionSuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :transfer_request

    def initialize(transfer_request)
      self.transfer_request = transfer_request
    end
  end

  class YesBank::Transfer::BankTransfer::TransactionFailurePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :transfer_request

    def initialize(transfer_request)
      self.transfer_request = transfer_request
    end
  end

  private

  def set_xml_params
    liquid_template = load_soap_template
    self.template = liquid_template.render(
        'UNIQUE_REFERENCE_NUMBER' => transfer_request.generate_unique_reference,
        'APP_ID' => application_id,
        'CUSTOMER_ID' => customer_id,
        'ACCOUNT_NUMBER' => account_number,
        'BENEFICIARY_NAME' => transfer_request.beneficiary_name,
        'BENEFICIARY_ACCOUNT_NUMBER' => transfer_request.beneficiary_account_number,
        'BENEFICIARY_IFSC' => transfer_request.ifsc,
        'TRANSFER_TYPE' => transfer_request.transfer_type,
        'TRANSFER_CURRENCY_CODE' => transfer_request.transfer_currency_code,
        'TRANSFER_AMOUNT' => transfer_request.transfer_amount
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