FactoryBot.define do

  factory :icici_bank_transaction do
    unique_request_number {(Faker::Alphanumeric.alphanumeric (10)).upcase}
    association :amount, factory: :amount
    association :transfer_status, factory: :open_transfer_status
  end
end