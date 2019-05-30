# == Schema Information
#
# Table name: rate_contract_line_items
#
#  id               :bigint           not null, primary key
#  location_id      :integer
#  item_id          :integer
#  start_date       :datetime
#  end_date         :datetime
#  rate_contract_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  amount_id        :integer
#

FactoryBot.define do
  factory :rate_contract_line_item do
    location_id { 1 }
    item_id { 1 }
    start_date { "2019-02-08 04:29:55" }
    end_date { "2019-02-08 04:29:55" }
    amount { "9.99" }
    rate_contract_id { 1 }
  end
end
