class BankAccountMaster < ApplicationRecord

  def as_json
    {
      id: id,
      account_name: account_name,
      account_number: account_name,
      ifsc: ifsc
    }
  end
end
