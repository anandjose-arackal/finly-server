# == Schema Information
#
# Table name: purchase_requests
#
#  id                         :bigint(8)        not null, primary key
#  description                :text(65535)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  purchase_request_status_id :integer
#  note                       :text(65535)
#  creator_id                 :integer
#  submitted_at               :datetime
#  approved_at                :datetime
#  order_number               :string(255)
#  reject_note                :text(65535)
#  location_id                :integer
#  department_id              :integer
#  policy_id                  :integer
#  controlling_level_id       :integer
#  company_id                 :integer
#  cost_center_id             :integer
#

FactoryBot.define do
  factory :purchase_request do
    
  end
end
