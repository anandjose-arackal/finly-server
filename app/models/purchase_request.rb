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
  include Transitionable
  # include Sequenced::ActsAsSequenced

  # belongs_to :purchase_request_status, optional: true
  belongs_to :status, optional: true, class_name: 'PurchaseRequestStatus', foreign_key: :purchase_request_status_id
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


  delegate :draft?, :retracted?, :rejected?, :awaiting_approval?, :approved?, :auto_approved?, :closed?, :order_initiated?, :cancelled?, to: :status

  before_save :add_company

  accepts_nested_attributes_for :purchase_request_items, :attachments, allow_destroy: true


  scope :filter_by_status_id,  -> (status_id) { where purchase_request_status_id: status_id }
  scope :search_by_email, -> (email) { where creator_id: User.find_by(email: email)&.id }

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
      status_attributes: {status_id: self.purchase_request_status_id, status_name: self.status&.name, display_name: self.status&.name&.humanize},
      creator_attributes: {creator_id: self.creator_id, creator_name: self.creator&.name, created_at: self.created_at.to_date },
      total_cost: calculate_total_amount
    }
  end

  def calculate_total_amount
    # amount_ids = self.purchase_request_items&.pluck(:estimated_amount_id)
    # Amount.where(id: amount_ids)&.pluck(:value).sum
    self.purchase_request_items.joins(:estimated_amount).pluck(:value)&.flatten&.compact&.sum rescue nil
  end

  def get_default_provider
    'PurchaseRequestProvider'
  end

  def self.document_owner_attribute
    'creator_id'
  end

  def self.document_status_attribute
    'purchase_request_status_id'
  end

  def self.document_status_class_name
    'PurchaseRequestStatus'
  end

  def self.status_ids(*statuses)
    status_ids = []
    statuses.each do |status|
      status_ids.push PurchaseRequestStatus.id_for(status)
    end
    status_ids&.flatten&.compact
  end

  # For user role as purchase request initiator
  def is_initiating_user?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:purchase_request_initiator), self)
  end

  # For user role as purchase request reviewer
  def is_reviewing_user?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:purchase_request_reviewer), self)
  end

  def reject_purchase_request_items(options={}, user)
    item_ids = options[:rejected_purchase_request_items]
    # Filter rejected ids
    filtered_item_ids = user.company.purchase_requests.joins(:purchase_request_items).where("purchase_request_items.id = (?)", item_ids).pluck('purchase_request_items.id')
    rejected_items = PurchaseRequestItem.with_ids(filtered_item_ids).update_all(rejected: true, status_id: PurchaseRequestItemStatus.id_for(:rejected)) unless filtered_item_ids.blank?
    return !rejected_items.zero? if filtered_item_ids.present?
    false
  end
end