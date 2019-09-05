FactoryBot.define do
  factory :payment_agreement_escalation do
    period_id { 1 }
    number { 1 }
    percentage_increment { "9.99" }
  end
end
