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
#  procurement_type      :string(255)
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

  default_scope {order(created_at: :desc)}

  scope :with_ids, -> (ids) {where id: ids}
  scope :order_by_controlling_user, ->(user_id) {
    if user_id.present?
      ids = pluck(:id)
      filtered_ids = PurchaseOrder.with_procurement_id(ids).with_controlling_user_id(user_id).pluck(:id)
      ordered_ids = filtered_ids + (ids - filtered_ids)
      find_ordered(ordered_ids)
    end
  }

  scope :order_by_controlling_level, ->(user_id) {
    if user_id.present?
      ids = pluck(:id)

      level_ids = LevelReviewerMapping.with_reviewer_id(user_id).pluck(:level_id)

      filtered_ids = PurchaseOrder.with_procurement_id(ids).with_controlling_level_ids(level_ids).pluck(:id)
      filtered_ids += Invoice.with_procurement_id(ids).with_controlling_level_ids(level_ids).pluck(:id)

      ordered_ids = filtered_ids + (ids - filtered_ids)
      find_ordered(ordered_ids)
    end
  }

  scope :filter_po_number, -> (po_number) {
    filtered_ids = PurchaseOrder.filter_po_number(po_number).pluck(:procurement_id)
    where id: filtered_ids
  }

  scope :filter_invoice_number, -> (invoice_number) {
    filtered_ids = Invoice.with_procurement.filter_invoice_number(invoice_number).pluck(:procurement_id)
    where id: filtered_ids
  }

  scope :filter_vendor_name, -> (name) {
    vendor_ids = YesBankVendor.filter_name_search(name).pluck(:id)

    procurement_ids = PurchaseOrder.with_vendor_ids(vendor_ids).pluck(:procurement_id)
    procurement_ids += Invoice.with_procurement.with_vendor_ids(vendor_ids).pluck(:procurement_id)

    where(id: procurement_ids)
  }

  scope :filter_status_tags, -> (ids) {
    all_status_tag_ids = StatusTag.all.pluck(:id)
    status_tag_ids = all_status_tag_ids & ids.map(&:to_i)

    procurement_status_taggables = ProcurementStatusTaggable.with_status_tag_ids(status_tag_ids).with_procurement_ids(pluck(:id))
    filter_procurement_ids = procurement_status_taggables.pluck(:procurement_id)

    where(id: filter_procurement_ids)
  }

  scope :include_details, -> {
    includes(
        {invoices: [:cost_center, :department, :sub_department, {vendor: :bank_accounts}]},
        {
            purchase_order: [:cost_center, :department, :sub_department, {vendor: :bank_accounts},
                             {balance_amount: [:currency]}, :status, {level: :reviewers}]
        },
        :status_tags, :user
    )
  }

  def awaiting_action?(user)
    # Ideal method:
    # First check if controlling user is present and return
    # If not, then check for controlling level and see if current user is present inside controlling level
    # Do it for both PO & Invoices
    if purchase_order.present? && !(invoices.length > 0)
      if user
        # Find document level reviewer mappings
        dlrm = purchase_order.document_level_reviewer_mappings.with_level_ids(purchase_order.level&.id)
        if dlrm.present?
          dlrm.pluck(:reviewer_id).include? user.id
        else
          purchase_order.level&.reviewers&.include? user
        end
      else
        false
      end
    else
      awaiting_action = false
      invoices.each do |invoice|
        if invoice.level&.reviewers&.include? user
          awaiting_action = true
          break
        end
      end

      awaiting_action
    end
  end

end
