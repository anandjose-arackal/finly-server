FactoryBot.define do

  factory :icici_bank_transaction do
    unique_request_number {(Faker::Alphanumeric.alphanumeric (10)).upcase}
    association :amount, factory: :amount
    transfer_status_id {BankTransferStatus.id_for(:open)}
  end
end