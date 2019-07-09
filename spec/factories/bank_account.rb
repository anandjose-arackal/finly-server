FactoryBot.define do

  factory :bank_account do
    name {"Test Bank Account"}

    # association :account_owner, factory: :yes_bank_vendor
    account_number {"30835594365"}
    ifsc {"SBIN0007990"}
  end
end