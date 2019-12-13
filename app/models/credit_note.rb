# == Schema Information
#
# Table name: credit_notes
#
#  id                            :bigint           not null, primary key
#  company_id                    :integer
#  user_id                       :integer
#  invoice_id                    :integer
#  procurement_id                :integer
#  status_id                     :integer
#  controlling_level_id          :integer
#  policy_id                     :integer
#  vendor_id                     :integer
#  shipping_location_id          :integer
#  billing_location_id           :integer
#  sequence_id                   :string(255)
#  credit_note_date              :date
#  narration                     :text(65535)
#  billing_address               :text(65535)
#  shipping_address              :text(65535)
#  gross_receivable_amount_id    :integer
#  gst_amount_id                 :integer
#  discount_amount_id            :integer
#  net_receivable_amount_id      :integer
#  tds_rate_id                   :integer
#  tds_amount_id                 :integer
#  freight_amount_id             :integer
#  previously_adjusted_amount_id :integer
#  net_adjustable_amount_id      :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  deleted_at                    :datetime
#  roundoff_amount_id            :integer
#  department_id                 :integer
#  cost_center_id                :integer
#

class CreditNote < ApplicationRecord
  include SoftDeletable, Templatable, Transitionable, MathUtil, CustomFieldFilterSupport
  include Sequenced::ActsAsSequenced

  belongs_to :company, optional: true
  belongs_to :user, optional: true
  belongs_to :status, class_name: "CreditNoteStatus", optional: true
  belongs_to :invoice, optional: true
  belongs_to :procurement, optional: true
  belongs_to :vendor, class_name: 'YesBankVendor', optional: true
  belongs_to :shipping_location, class_name: 'BranchLocation', optional: true
  belongs_to :billing_location, class_name: 'BranchLocation', optional: true
  belongs_to :tds_rate, class_name: 'TdsRatesList', optional: true
  belongs_to :department, class_name: 'Department', optional: true
  belongs_to :cost_center, class_name: 'CostCenter', optional: true

  belongs_to :gross_receivable_amount, class_name: 'Amount', optional: true
  belongs_to :gst_amount, class_name: 'Amount', optional: true
  belongs_to :discount_amount, class_name: 'Amount', optional: true
  belongs_to :net_receivable_amount, class_name: 'Amount', optional: true
  belongs_to :tds_amount, class_name: 'Amount', optional: true
  belongs_to :freight_amount, class_name: 'Amount', optional: true
  belongs_to :previously_adjusted_amount, class_name: 'Amount', optional: true
  belongs_to :net_adjustable_amount, class_name: 'Amount', optional: true

  belongs_to :tds_rate_id, class_name: 'TdsRatesList', optional: true

  has_many :items, class_name: 'CreditNoteItem', dependent: :destroy

  delegate :draft?, :awaiting_approval?, :retracted?, :rejected?, :approved?, :auto_approved?, :voided?, :adjusted?, :partially_adjusted?, to: :status

  def as_json(options = {})
    if options[:index]
      {}
    else
      {
          id: id,
          procurement_id: procurement_id,
          gst_amount: precision_value(gst_amount&.value),

          # gst_type_id: gst_type_id,
          date: credit_note_date,
          created_at: created_at.strftime('%d %b %Y'),
          updated_at: updated_at.strftime('%d %b %Y'),

          invoice_number: invoice&.invoice_number,
          freight_amount: freight_amount&.value,
          # roundoff_amount: roundoff_amount,
          tds_amount: precision_value(tds_amount&.value),
          # attachment: attachments.as_json,

          # custom_fields: self.custom_fields,

          cost_center: cost_center.as_json,
          department: department.as_json,
          policy: policy.as_json,
          items: items.as_json,
          # note: note,
      }
    end
  end

  def self.document_owner_attribute
    'user_id'
  end

  def self.document_status_attribute
    'status_id'
  end

  def self.document_status_class_name
    'CreditNoteStatus'
  end

  def self.role_based_associated_status_ids(user)
    CreditNoteStatus.ids_for(self.role_based_statuses(user))
  end

  def self.role_based_statuses(user)
    statuses = []
    if user.policy_user_roles.pluck(:user_role_id).uniq.present?
      user.policy_user_roles.pluck(:user_role_id).uniq.each do |role_id|
        if [UserRole.id_for(:credit_note_initiator)]
          statuses += [:draft, :retracted, :awaiting_approval, :approved, :rejected, :auto_approved, :voided]
        elsif [UserRole.id_for(:credit_note_reviewer)]
          statuses += [:retracted, :awaiting_approval, :approved, :rejected, :voided]
        elsif UserRole.id_for(:admin) == role_id.to_i
          statuses += [:retracted, :awaiting_approval, :approved, :rejected, :auto_approved, :voided]
        end
      end
    end
    return statuses.uniq
  end

  def self.open_status_ids(user)
    CreditNoteStatus.ids_for(:draft)
  end

  def self.finance_associated_status_ids
    CreditNoteStatus.ids_for(:approved, :auto_approved, :voided)
  end

  def self.auditor_associated_status_ids
    CreditNoteStatus.ids_for([:approved, :auto_approved, :awaiting_approval, :rejected, :retracted, :voided])
  end

  def self.roles
    [
        :purchase_order_initiator,
        :purchase_order_reviewer,
        :purchase_order_auditor,
        :po_invoice_initiator,
        :po_invoice_reviewer,
        :po_invoice_auditor,
        :non_po_invoice_initiator,
        :non_po_invoice_reviewer,
        :non_po_invoice_auditor,
        :credit_note_initiator,
        :credit_note_reviewer,
        :credit_note_auditor,
        :bank_payment_request_initiator,
        :bank_payment_request_reviewer,
        :bank_payment_request_creditor,
        :bank_payment_request_auditor
    ]
  end

  def self.status_ids(*statuses)
    status_ids = []
    statuses.each do |status|
      status_ids.push CreditNoteStatus.id_for(status)
    end

    status_ids.reject {|status_id| status_id.nil?}
  end
end
