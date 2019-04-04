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

  belongs_to :purchase_request_status, optional: true
  belongs_to :department, optional: true
  belongs_to :location, optional: true, class_name: "BranchLocation"
  belongs_to :policy, optional: true
  belongs_to :company, optional: true
  belongs_to :creator, optional: true, class_name: 'User'
  belongs_to :level, optional: true, class_name: 'ReviewalLevel', foreign_key: :controlling_level_id
  belongs_to :purchase_order, optional: true
  has_many :attachments, as: :resource, dependent: :destroy

  # has_many :line_items, class_name: "PurchaseRequestItem", dependent: :destroy
  has_many :purchase_request_items, dependent: :destroy

  before_save :add_company

  accepts_nested_attributes_for :purchase_request_items, :attachments, allow_destroy: true

  def add_company
    self.company_id = self.creator.company_id
  end

  def as_json
    {
      id: self.id,
      purchase_request_number: self.id,
      description: self.description,
      location_attributes: {id: self.location_id, name: self.location&.name},
      department_attributes: {id: self.department_id, name: self.department&.name},
      policy_attributes: {id: self.policy_id, name: self.policy&.name},
      status_attributes: {status_id: self.purchase_request_status_id, status_name: self.purchase_request_status&.name, display_name: self.purchase_request_status&.name},      
      creator_attributes: {creator_id: self.creator_id, creator_name: self.creator&.name, created_at: self.created_at.to_date}
    }
  end

end
