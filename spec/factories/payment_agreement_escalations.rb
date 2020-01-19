# == Schema Information
#
# Table name: payment_agreement_escalations
#
#  id                   :bigint           not null, primary key
#  period_id            :integer
#  number               :integer
#  percentage_increment :decimal(10, )
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  invoice_id           :integer
#  start_date           :datetime
#  end_date             :datetime
#  revised_amount_id    :integer
#  uuid                 :string(36)
#

FactoryBot.define do
  factory :payment_agreement_escalation do
    period_id { 1 }
    number { 1 }
    percentage_increment { "9.99" }
  end
end
