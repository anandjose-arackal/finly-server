# == Schema Information
#
# Table name: invoice_frequencies
#
#  id         :bigint           not null, primary key
#  number     :integer
#  period_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :invoice_frequency do
    number { 1 }
    period_id { 1 }
  end
end
