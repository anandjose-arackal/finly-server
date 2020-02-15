# == Schema Information
#
# Table name: security_deposits
#
#  id                              :bigint           not null, primary key
#  vendor_id                       :integer
#  vendor_location_id              :integer
#  cost_center_id                  :integer
#  department_id                   :integer
#  location_id                     :integer
#  note                            :text(65535)
#  description                     :text(65535)
#  payable_amount_id               :integer
#  original_amount_id              :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  payment_agreement_id            :integer
#  bank_account_id                 :integer
#  company_id                      :integer
#  creator_id                      :integer
#  payment_agreement_upcoming_date :date
#  status_id                       :integer
#  uuid                            :string(36)
#  deleted_at                      :datetime
#

FactoryBot.define do
  factory :security_deposit do
    vendor_id { 1 }
    vendor_location_id { 1 }
    cost_center_id { 1 }
    department_id { 1 }
    location_id { 1 }
    note { "MyText" }
    description { "MyText" }
    payable_amount_id { 1 }
    original_amount_id { 1 }
  end
end
