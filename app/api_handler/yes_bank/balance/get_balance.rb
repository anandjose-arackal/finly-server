# this API retrieves the balance of the

class YesBank::Balance::GetBalance < YesBank::Base

  attr_accessor :customer_id, :account_number, :company

  def initialize(company)
    self.company = company
  end

  def pre_validate
    if user.blank?
      add_message :error, "User not found, try again"
    end
  end

  def yes_bank_action
    'get_balance'
  end

  def init
    super()
    self.account_number = YAML.load_file(config_path)[Rails.env][:account_number]
    self.customer_id = "448995" # todo - get more clarity on this parameter, if it's specific to each client or Finly as a whole
  end

end