# this API retrieves the balance of Finly's current account as a whole
# which is the sum of all accounts we are maintaining in the system

class YesBankApi::Status::GetStatus < YesBankApi::Base

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

  def post_process
    case self.response.status_code
      when 404
        # handle cases when the API is not up
        add_message :error, "The service is temporarily down. Please try again later"
        self.request_status = "Service is temporarily down"
      when 500
        # handle error
        self.parsed_response = Hash.from_xml(response.body)
        set_response_parameters
      when 200
        # handle success cases
        self.parsed_response = Hash.from_xml(response.body)
        set_response_parameters
      else
        # do nothing?
    end
    # self.parsed_response = Hash.from_xml(response.body)
    ap parsed_response
    # set_response_parameters
  end

  def success?
    unless parsed_response["Envelope"]&.dig("Body")&.dig("getStatusResponse")&.dig("transactionStatus")&.dig("statusCode").present?
      return false
    end
    # now that we have the response status, we can determine if the request is legit or not
    unless self.request_status.downcase == "request not found"
      return true
    end
    false
  end

  def failure?
    has_errors? || self.request_status.downcase == "request not found"
  end

  def success
    params[:request_status] = request_status
    YesBankApi::Status::GetStatus::SuccessStatusPresenter.new(params)
  end

  def failure
    params[:request_status] = request_status
    YesBankApi::Status::GetStatus::SuccessStatusPresenter.new(params)
  end

  class YesBankApi::Status::GetStatus::SuccessStatusPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :request_status

    def initialize(params)
      self.request_status = params[:request_status]
    end
  end

  class YesBankApi::Status::GetStatus::FailureStatusPresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :request_status

    def initialize(params)
      self.request_status = params[:request_status]
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