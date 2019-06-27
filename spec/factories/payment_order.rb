FactoryBot.define do

  factory :payment_order do
    payment_purpose_id {PaymentPurpose.id_for(:vendor_payment)}
    currency
    association :amount_requested, factory: :amount
    application {"vp"}
    receiving_account_type {"BankAccount"}

    factory :yes_bank_payment_order do
      initiating_account_type {"YesBankCompanyAccount"}
      bank_account_provider_id {BankAccountProvider.id_for(:yes_bank)}
    end

    factory :icici_bank_payment_order do
      initiating_account_type {"IciciBankCompanyAccount"}
      bank_account_provider_id {BankAccountProvider.id_for(:icici_bank)}
    end

  end
end