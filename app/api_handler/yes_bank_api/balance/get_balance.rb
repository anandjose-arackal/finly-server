# this API retrieves the balance of Finly's current account as a whole
# which is the sum of all account we are maintaining in the system

class YesBankApi::Balance::GetBalance < YesBankApi::Base

  attr_accessor :account_number, :balance, :company

  def initialize(company)
    self.company = company
  end

  def self.call(company)
    self.new(company).run
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
    set_xml_params
  end

  def validate
    super
    if self.account_number.blank?
      add_message :error, "No account number present"
    end
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
    YesBankApi::Transfer::BankTransfer::SuccessBalancePresenter.new(balance)
  end

  def failure
    YesBankApi::Transfer::BankTransfer::FailureBalancePresenter.new(nil, nil, messages)
  end

  class YesBankApi::Transfer::BankTransfer::SuccessBalancePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :balance

    def initialize(balance)
      self.balance = balance
    end
  end

  class YesBankApi::Transfer::BankTransfer::FailureBalancePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :balance

    def initialize
      self.balance = 0
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