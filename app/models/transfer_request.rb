# A non persistent model that holds information about a particular bank transfer
# contains shit like account number, ifsc, beneficiary name etc.

class TransferRequest

  attr_accessor :beneficiary_account_number, :ifsc, :beneficiary_name, :transfer_type,
                :transfer_currency_code, :transfer_amount, :errors

  def initialize
    self.transfer_currency_code = "INR" # todo - for now, once international payments are supported, they can be implemented accordingly
    self.errors = []
  end

  def valid?
    self.errors = []
    if beneficiary_account_number.blank?
      self.errors << "Beneficiary account can't be blank"
      return false
    end
    if ifsc.blank?
      self.errors << "IFS code can't be blank"
      return false
    end
    if beneficiary_name.blank?
      self.errors << "Beneficiary name can't be blank"
      return false
    end
    if transfer_type.blank?
      self.errors << "Transfer type can't be blank"
      return false
    end
    if transfer_currency_code.blank?
      self.transfer_currency_code << "INR" # setting this by default because now the
    end
    if transfer_amount.blank?
      self.errors << "Transfer amount can't be blank"
      return false
    end
    true
  end
end