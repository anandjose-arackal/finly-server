# this API retrieves the balance of Finly's current account as a whole
# which is the sum of all accounts we are maintaining in the system

class YesBank::Status::GetStatus < YesBank::Base

  attr_accessor :request_reference_number, :request_status, :transaction_status,
                :bank_error_message

  def initialize(params)
    self.params = params
  end

  def self.call(params)
    self.new(params).run
  end

  # defines the respective action that this API handler is executing
  # used for retrieving the right soap template
  def yes_bank_action
    'get_status'
  end

  def pre_validate
    if params.blank?
      add_message :error, "Invalid parameters"
      return
    end
  end

  def init
    super()
    self.request_reference_number = params[:request_reference_number]
    set_xml_params
  end

  def success?
    self.parsed_response = Hash.from_xml(response.body)
    ap parsed_response
    unless parsed_response["Envelope"]&.dig("Body")&.dig("getStatusResponse")&.dig("transactionStatus")&.dig("statusCode").present?
      return false
    end
    set_response_parameters
    # now that we have the response status, we can determine is the request is legit or not
    unless self.request_status.downcase == "request not found"
      return true
    end
    false
  end

  def post_process

  end

  def failure?

  end

  def success
    params[:request_status] = request_status
    YesBank::Transfer::BankTransfer::TransactionSuccessPresenter.new(transfer_request)
  end

  def failure

  end

  class YesBank::Transfer::BankTransfer::SuccessStatusPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :transfer_request

    def initialize(transfer_request)
      self.transfer_request = transfer_request
    end
  end

  private

  def set_xml_params
    liquid_template = load_soap_template
    self.template = liquid_template.render(
        'APP_ID' => application_id,
        'CUSTOMER_ID' => customer_id,
        'REFERENCE_NO' => request_reference_number,
    )
  end

  def set_response_parameters
    self.request_status = parsed_response["Envelope"]&.dig("Body")&.dig("getStatusResponse")&.dig("transactionStatus")&.dig("statusCode")
  end

end