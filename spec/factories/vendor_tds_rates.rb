# == Schema Information
#
# Table name: vendor_tds_rates
#
#  id                :bigint           not null, primary key
#  vendor_id         :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  tds_rates_list_id :integer
#

FactoryBot.define do
  factory :vendor_tds_rate do
    vendor_id { 1 }
    tds_rates_list { nil }
  end
end
