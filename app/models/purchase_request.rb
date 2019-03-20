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

  belongs_to :status, optional: true, class_name: "PurchaseRequestStatus", foreign_key: :purchase_request_status_id
  belongs_to :department, optional: true
  belongs_to :location, optional: true, class_name: "BranchLocation"
  belongs_to :policy, optional: true
  belongs_to :company, optional: true
  belongs_to :creator, optional: true, class_name: 'User'
  belongs_to :level, optional: true, class_name: 'ReviewalLevel', foreign_key: :controlling_level_id

  # has_many :line_items, class_name: "PurchaseRequestItem", dependent: :destroy
  has_many :purchase_request_items, dependent: :destroy

  before_save :add_company

  accepts_nested_attributes_for :purchase_request_items

  def add_company
    self.company_id = self.creator.company_id
  end

end
