# this API retrieves the balance of Finly's current account as a whole
# which is the sum of all accounts we are maintaining in the system

class KotakBankApi::TransactionStatus < KotakBankApi::Base
  attr_accessor :request_reference_number, :request_status, :bank_status_code, :bank_transaction, :retry,
                :bank_message, :bank_message_type, :bank_reference_number, :company_id, :transfer_status_id, :payment, :new_message_id

  def initialize(params)
    self.params = params
    self.company_id = params[:company_id]
  end

  def self.call(params)
    self.new(params).run
  end

  # defines the respective action that this API handler is executing
  # used for retrieving the right soap template
  def bank_action
    'transaction_status'
  end

  def file_logger_base_params
    {
        company_id: params&.dig(:company_id),
        company_name: Company.find_by(id: params&.dig(:company_id))&.name,
        unique_reference_number: params&.dig(:unique_request_number),
        action: bank_action
    }
  end

  def pre_validate
    if params.blank?
      add_message :error, "Invalid parameters"
      return
    end


  end

  def init
    super()
    self.request_reference_number = params[:request_reference_number] || params[:unique_reference_number]
    self.bank_transaction = params[:bank_transaction]
    self.payment = self.bank_transaction.reference_payment
    set_xml_params
  end

  def validate
    super()
    unless bank_transaction.present?
      add_message :error, "Kotak Bank Transaction not found"
    end

    unless payment.present?
      add_message :error, "Payment not found for bank transaction"
      Event::EAlert::Create.(nil, title: 'Payment not found for Kotak Bank Transaction while Status Check', description: "Kotak Bank Transaction: #{self.response.to_json}", subject: 'Payment not found for Kotak Bank Transaction')
    end
  end

  def post_process

    case self.response.status
    when 400
      add_message :error, "Invalid API Key"
      self.request_status = "Service is temporarily down"
    when 403
      add_message :error, "Schema Validation Error"
      self.request_status = "Service is temporarily down"
    when 404
      add_message :error, "The service is temporarily down. Please try again later"
      self.request_status = "Service is temporarily down"
    when 401
      add_message :error, "Unauthorized."
      self.request_status = "Service is temporarily down"
    when 500
      self.parsed_response = Hash.from_xml(response.body)
      ap parsed_response
      set_failure_response_parameters # todo - kotak
    when 200
      self.parsed_response = Hash.from_xml(response.body)

      ap parsed_response
      # if the below is nil, i.e. the transaction most likely failed, the transaction result won't be either of the success ones
      acknowledgement = parsed_response["Envelope"]&.dig("Body")&.dig("Reversal")&.dig("Details")&.dig("Rev_Detail")

      status_code = acknowledgement["Status_Code"]
      if status_code.present?
        case status_code
        when "RE"
          # Rejected | Reinitiate transactions with correct details and new message id
          self.bank_message = "Rejected. Re-initiate Transaction"
          self.bank_message_type = "error"
          self.new_message_id = true
          self.retry = true
          self.bank_status_code = status_code
          self.transfer_status_id = BankTransferStatus.id_for(:failed)
        when "AR"
          # Auth Rejected | Reprocess with new message id
          self.bank_message = "Auth Rejected. Re-initiate Transaction"
          self.bank_message_type = "error"
          self.new_message_id = true
          self.retry = true
          self.bank_status_code = status_code
          self.transfer_status_id = BankTransferStatus.id_for(:failed)
        when "DF"
          # Insufficient Funds
          self.bank_message = "Insufficient Funds"
          self.bank_message_type = "error"
          self.new_message_id = true
          self.retry = true
          self.bank_status_code = status_code
          self.transfer_status_id = BankTransferStatus.id_for(:failed)
        when "Error-101"
          # Data not found | Wait for 30 mins
          self.bank_status_code = status_code
          self.transfer_status_id = BankTransferStatus.id_for(:pending)
          # Error | Invalid Client Code
        when "Error-99"
          # Transaction in Progress
          self.bank_message = "Transaction in Progress"
          self.bank_message_type = "info"
          self.bank_status_code = status_code
          self.transfer_status_id = BankTransferStatus.id_for(:processing)
          # Error | Duplicate Instrument Ref Number within Request
        when "CR"
          # Invalid IFS Code | Re initiate payment
          self.bank_message = "Invalid IFS Code"
          self.bank_message_type = "error"
          self.bank_status_code = status_code
          self.transfer_status_id = BankTransferStatus.id_for(:failed)
        when "C"
          # Received | Received -Uploaded at portal successfully. No action to be taken.
          self.bank_status_code = status_code

          if self.bank_reference_number.present? || acknowledgement["UTR"].is_a?(String)
            self.transfer_status_id = BankTransferStatus.id_for(:completed)
          else
            self.bank_message_type = "info"
            self.transfer_status_id = BankTransferStatus.id_for(:pending_utr)
          end
        when "UP"
          # Transaction Timeout | Manual confirmation to be sought from bank and in case of reject – reinitiate same transaction with fresh message id.
          self.bank_message = "Transaction Timeout. Manual Confirmation to be sought from bank and in case of reject, Re Initiate Fresh Transaction"
          self.bank_message_type = "error"
          self.bank_status_code = status_code
          self.transfer_status_id = BankTransferStatus.id_for(:possible_failure)
        when "U"
          # Paid | - Success with UTR No provided. No action to be taken.
          self.bank_status_code = status_code
          if acknowledgement["UTR"].present? || acknowledgement["UTR"].is_a?(String)
            self.transfer_status_id = BankTransferStatus.id_for(:completed)
            self.bank_reference_number = acknowledgement["UTR"]
          else
            self.transfer_status_id = BankTransferStatus.id_for(:pending_utr)
          end
        when "CF"
          # Account Doesn't Exist | Incorrect beneficiary account number details. Repush the transaction with correct beneficiary details and new message id
          self.bank_message = "Account Doesn't Exist. Incorrect Beneficiary Account Number Details provided"
          self.bank_message_type = "error"
          self.bank_status_code = status_code
          self.transfer_status_id = BankTransferStatus.id_for(:failed)
        when "R"
          # Rejected | XML/Data Validation failed.You can repush with new message id.
          self.bank_message = "Rejected. Transaction can be initiated again"
          self.bank_message_type = "error"
          self.retry = true
          self.bank_status_code = status_code
          self.transfer_status_id = BankTransferStatus.id_for(:failed)
          # Error | Default user not found for given client
        end
      else
        # Did not get expected response
        add_message :error, "Unknown Response"
        self.transfer_status_id = BankTransferStatus.id_for(:failed)
      end
    else
      # Nothing to do
      add_message :error, "Something went wrong"
      Event::EAlert::Create.(nil, title: 'Kotak Status API responded w/ 200 & w/o valid status', description: "Kotak Bank Transaction: #{self.response.to_json}", subject: 'Status 200 w/o valid Status Code')
      return
    end

    # Update Payment & KotakBankTransaction
    if BankTransferStatus.all.pluck(:id).include?(self.transfer_status_id)

      reversal_api_counter = bank_transaction.reversal_api_counter + 1
      self.bank_transaction.update({
          transfer_status_id: self.transfer_status_id,
          reversal_status_code: self.bank_status_code,
          reversal_response: self.bank_message,
          reversal_api_counter: reversal_api_counter
      })
    end
    case self.transfer_status_id
    when BankTransferStatus.id_for(:failed)
      payment.update({payment_status_id: PaymentStatus.id_for(:failed)})
      payment.system_messages.destroy_all
      payment.system_messages.create({
                                         content: bank_message,
                                         system_message_type_id: SystemMessageType.id_for(bank_message_type.to_sym)
                                     })
      payment.payment_order&.update_order_status
    when BankTransferStatus.id_for(:processing)
      payment.update({payment_status_id: PaymentStatus.id_for(:initiated)})
      payment.system_messages.destroy_all
      payment.system_messages.create({
                                         content: bank_message,
                                         system_message_type_id: SystemMessageType.id_for(bank_message_type.to_sym)
                                     })
      payment.payment_order&.update_order_status
    when BankTransferStatus.id_for(:pending_utr)
      payment.update({payment_status_id: PaymentStatus.id_for(:completed)})
      payment.system_messages.destroy_all
      payment.system_messages.create({
                                         content: "Processed at Bank's end, Pending UTR",
                                         system_message_type_id: SystemMessageType.id_for(bank_message_type.to_sym)
                                     })
      payment.payment_order&.update_order_status
    when BankTransferStatus.id_for(:completed)
      # Change status of payment to completed
      payment.update({payment_status_id: PaymentStatus.id_for(:completed)})
      payment.system_messages.destroy_all
      payment.payment_order&.update_order_status
      self.bank_transaction.update({utr: self.bank_reference_number})
    when BankTransferStatus.id_for(:possible_failure)
      payment.update(payment_status_id: PaymentStatus.id_for(:possible_failure))
      payment.system_messages.destroy_all
      payment.system_messages.create({
                                         content: bank_message,
                                         system_message_type_id: SystemMessageType.id_for(bank_message_type.to_sym)
                                     })
      payment.payment_order&.update_order_status
    else
      # Do nothing
    end
    #
  end

  # def success?
  #   unless parsed_response["Envelope"]&.dig("Body")&.dig("Reversal")&.dig("Details")&.dig("Rev_Detail")&.dig("Status_Code").present?
  #     return false
  #   end
  #   true
  # end

  def failure?
    has_errors?
  end

  def success
    params[:request_status] = request_status
    params[:bank_reference_number] = self.bank_reference_number
    params[:bank_message_type] = self.bank_message_type
    params[:bank_message] = self.bank_message
    params[:transfer_status_id] = self.transfer_status_id
    params[:bank_transaction] = self.bank_transaction
    params[:payment] = self.payment
    KotakBankApi::TransactionStatus::SuccessStatusPresenter.new(params)
  end

  def failure
    params[:request_status] = request_status
    params[:bank_message_type] = self.bank_message_type
    params[:bank_message] = self.bank_message
    KotakBankApi::TransactionStatus::FailureStatusPresenter.new(params)
  end

  class KotakBankApi::TransactionStatus::SuccessStatusPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :request_status, :bank_reference_number, :bank_message_type, :bank_message, :transfer_status_id

    def initialize(params)
      self.request_status = params[:request_status]
      self.bank_reference_number = params[:bank_reference_number]
      self.bank_message = params[:bank_message]
      self.bank_message_type = params[:bank_message_type]
      self.transfer_status_id = params[:transfer_status_id]
    end
  end

  class KotakBankApi::TransactionStatus::FailureStatusPresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :request_status, :bank_message, :bank_message_type

    def initialize(params)
      self.request_status = params[:request_status]
      self.bank_message = params[:bank_message]
      self.bank_message_type = params[:bank_message_type]
    end
  end

  private

  def set_xml_params
    liquid_template = load_soap_template
    self.template = liquid_template.render(
        'UNIQUE_REFERENCE_NUMBER' => self.request_reference_number,
        'MESSAGE_SOURCE' => 'FINLY',
        'CLIENT_CODE' => "#{self.configuration['CLIENT_CODE']}",
        'DATE' => "#{Date.today.strftime("%d-%m-%Y")}"
    )
  end

  # def set_success_response_parameters
  #   self.request_status = parsed_response["Envelope"]&.dig("Body")&.dig("getStatusResponse")&.dig("transactionStatus")&.dig("statusCode")
  #   self.bank_reference_number = parsed_response["Envelope"]&.dig("Body")&.dig("getStatusResponse")&.dig("transactionStatus")&.dig("bankReferenceNo")
  # end
  #
  # def set_failure_response_parameters
  #   self.request_status = parsed_response["Envelope"]&.dig("Body")&.dig("Fault")&.dig("Reason")&.dig("Text")
  #   self.bank_reference_number = ""
  # end
end