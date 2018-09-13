# == Schema Information
#
# Table name: procurements
#
#  id                    :integer          not null, primary key
#  name                  :string(255)
#  procurement_track_id  :integer
#  procurement_status_id :integer
#  vendor_id             :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  user_id               :integer
#  company_id            :integer
#  note                  :text(65535)
#  is_deleted            :boolean          default(FALSE), not null
#

class Procurement < ActiveRecord::Base
  include SoftDeletable, FindByOrderedIds
  belongs_to :user
  belongs_to :company
  belongs_to :procurement_track
  belongs_to :procurement_status
  belongs_to :vendor, class_name: "YesBankVendor"

  has_one :purchase_order, dependent: :destroy
  has_many :inward_documents, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :bill_of_supplies, dependent: :destroy
  has_many :delivery_challans, dependent: :destroy
  has_many :e_way_bills, dependent: :destroy
  has_many :procurement_status_taggables, dependent: :destroy

  has_many :comments, class_name: 'ProcurementComment', as: :parent_commentable, dependent: :destroy

  has_many :status_tags, through: :procurement_status_taggables, dependent: :destroy

  default_scope { order(updated_at: :desc) }

  scope :with_ids, -> (ids) {where id: ids}
  scope :order_by_controlling_user, ->(user_id) {
    if user_id.present?
      ids = pluck(:id)
      filtered_ids = PurchaseOrder.with_procurement_id(ids).with_controlling_user_id(user_id).pluck(:id)
      ordered_ids = filtered_ids + (ids - filtered_ids)
      find_ordered(ordered_ids)
    end
  }

  def awaiting_action?(user)
    user and purchase_order.controlling_user_id == user.id
  end

end
