class Company::Balances::SetBalances < BaseOperation

  attr_accessor :company

  def initialize(company, params)
    self.company = company
    self.params = params
  end

  def pre_validate
    if company.blank? || params.blank?
      add_message :errors, "Invalid parameters"
      return
    end
  end

  def init

  end

  def process
    params = extract_balance_params(company)
    balance_history = company.company_balance_histories.new(params)
    # no question of error messages as this is a background task
    balance_history.save
  end

  private

  def extract_balance_params(company)
    p = {}
    neft_transfer_total = 0
    transfers_to_company_account = 0
    transfers_from_company_account = 0
    
  end

end
