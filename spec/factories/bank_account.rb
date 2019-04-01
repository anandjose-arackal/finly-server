FactoryBot.define do

  factory :bank_account do
    name {"Test Bank Account"}
    company_id {1}
    account_number {"30835594365"}
    ifsc {"SBIN0007990"}
  end
end