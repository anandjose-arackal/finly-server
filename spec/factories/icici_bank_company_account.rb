FactoryBot.define do

  factory :icici_bank_company_account do
    company_id {1}
    association :balance, factory :user, value: 10000000000
  end
end