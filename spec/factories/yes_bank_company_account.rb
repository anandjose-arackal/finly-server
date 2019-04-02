FactoryBot.define do

  factory :yes_bank_company_account do
    company
    association :balance, factory: :user, value: 10000000000
  end
end