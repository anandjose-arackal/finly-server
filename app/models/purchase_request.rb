# == Schema Information
#
# Table name: purchase_requests
#
#  id                   :bigint(8)        not null, primary key
#  title                :text(65535)
#  user_id              :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  location_id          :integer
#  department_id        :integer
#  policy_id            :integer
#  controlling_level_id :integer
#  company_id           :integer
#

class PurchaseRequest < ApplicationRecord

  belongs_to :status, class_name: "PurchaseRequestStatus"
  belongs_to :department
  belongs_to :location, class_name: "BranchLocation"
  belongs_to :policy
  belongs_to :company

  belongs_to :level, optional: true, class_name: 'ReviewalLevel', foreign_key: :controlling_level_id
end
