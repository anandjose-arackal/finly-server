# this API retrieves the balance of Finly's current account as a whole
# which is the sum of all account we are maintaining in the system

class YesBank::Balance::GetBalance < YesBank::Base

  attr_accessor :account_number, :balance

  def initialize(params)
    self.params = params
  end

  def self.call(params)
    self.new(params).run
  end

  # defines the respective action that this API handler is executing
  # used for retrieving the right soap template
  def yes_bank_action
    'get_balance'
  end

  def pre_validate
    if params.blank?
      add_message :error, "Invalid parameters"
      return
    end
  end

  def init
    super()
    self.account_number = params[:account_number]
    set_xml_params
  end

  def success?
    self.parsed_response = Hash.from_xml(response.body)
    ap parsed_response
    unless parsed_response["Envelope"]&.dig("Body")&.dig("getBalanceResponse")&.dig("accountBalanceAmount").present?
      return false
    end
    set_response_parameters
  end

  def failure?

  end

  def success
    YesBank::Transfer::BankTransfer::TransactionSuccessPresenter.new(balance)
  end

  def failure

  end

  class YesBank::Transfer::BankTransfer::SuccessStatusPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :balance

    def initialize(balance)
      self.balance = balance
    end
  end

  private

  def set_xml_params
    liquid_template = load_soap_template
    self.template = liquid_template.render(
        'APP_ID' => application_id,
        'CUSTOMER_ID' => customer_id,
        'ACCOUNT_NUMBER' => account_number,
    )
  end

  def set_response_parameters
    self.balance = parsed_response["Envelope"]&.dig("Body")&.dig("getBalanceResponse")&.dig("accountBalanceAmount")
  end

end