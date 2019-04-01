FactoryBot.define do

  factory :payment_order do
    payment_purpose_id {PaymentPurpose.id_for(:vendor_payment)}
    company_id {1}
    currency_id {1}
    initiating_user_id {1}

    factory :new_payment_order do
      payment_order_status_id {PaymentPurpose.id_for(:pending_approval)}
    end

    factory :credited_payment_order do
      payment_order_status_id {PaymentPurpose.id_for(:completed)}
    end

    factory :partially_credited_payment_order do
      payment_order_status_id {PaymentPurpose.id_for(:partially_completed)}
    end

    factory :failed_payment_order do
      payment_order_status_id {PaymentPurpose.id_for(:failed)}
    end
  end
end