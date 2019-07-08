FactoryBot.define do

  factory :payment do
    amount
    date {Date.today}
    application {"vp"}


    factory :icici_bank_payment do
      payment_type_id {PaymentType.id_for(:credit)} # todo - can split between credit and debit payment
      bank_account_provider_id {BankAccountProvider.id_for(:icici_bank)}
    end

    factory :yes_bank_payment do
      payment_type_id {PaymentType.id_for(:credit)} # todo - can split between credit and debit payment
      bank_account_provider_id {BankAccountProvider.id_for(:yes_bank)}
    end

  end

end