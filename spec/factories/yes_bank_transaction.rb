FactoryBot.define do

  factory :yes_bank_transaction do
    unique_request_number {(Faker::Alphanumeric.alphanumeric (10)).upcase}
    association :amount, factory: :amount
    transfer_status_id {BankTransferStatus.id_for(:open)}
    transfer_type {"IMPS"}
  end

end