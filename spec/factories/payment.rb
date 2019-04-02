FactoryBot.define do

  factory :payment do
    amount
    initiating_user_id {1}
    receiving_user_id {1}
    association :receiving_account, factory: :bank_account
    payment_order_id {1}
    date {Date.today}
    application {"vp"}


    factory :icici_bank_payment do
      association :initiating_account, factory: :icici_bank_company_account
      payment_type_id {PaymentType.id_for(:credit)} # todo - can split between credit and debit payment

      association :reference_resource, factory: :icici_bank_transaction

      factory :icici_bank_credit_payment do
        payment_type_id {PaymentType.id_for(:credit)}
      end
    end

    factory :yes_bank_payment do
      association :initiating_account, factory: :yes_bank_company_account
      payment_type_id {PaymentType.id_for(:credit)} # todo - can split between credit and debit payment

      association :reference_resource, factory: :yes_bank_transaction

      factory :yes_bank_credit_payment do
        payment_type_id {PaymentType.id_for(:credit)}
      end
    end

  end

end