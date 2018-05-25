# == Schema Information
#
# Table name: purchase_orders
#
#  id                       :integer          not null, primary key
#  company_id               :integer
#  procurement_id           :integer
#  location_id              :integer
#  delivery_location_id     :integer
#  vendor_id                :integer
#  payment_term_id          :integer
#  procurement_term_id      :integer
#  purchase_order_status_id :integer
#  indent_number            :string(255)
#  indent_date              :date
#  po_number                :string(255)
#  override_po_number       :boolean
#  prefix                   :string(255)
#  sequence_start           :string(255)
#  delivery_date            :date
#  gst_type_id              :integer
#  inclusive_of_taxes       :boolean
#  roundoff_total_enabled   :boolean
#  roundoff_amount          :decimal(10, 5)
#  transaction_amount_id    :integer
#  total_before_tax_id      :integer
#  tax_amount_id            :integer
#  total_after_tax_id       :integer
#  discount_amount_id       :integer
#  balance_amount_id        :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  user_id                  :integer
#

class PurchaseOrder < ActiveRecord::Base
  belongs_to :company
  belongs_to :procurement
  belongs_to :location, class_name: "BranchLocation"
  belongs_to :delivery_location, class_name: "BranchLocation"
  belongs_to :vendor, class_name: "YesBankVendor"
  belongs_to :payment_term
  belongs_to :procurement_term
  belongs_to :purchase_order_status

  belongs_to :total_before_tax, class_name: "Amount"
  belongs_to :tax_amount, class_name: "Amount"
  belongs_to :total_after_tax, class_name: "Amount"
  belongs_to :discount_amount, class_name: "Amount"
  belongs_to :balance_amount, class_name: "Amount"

  has_many :items, class_name: "PurchaseOrderItem"
  has_many :extra_charges, class_name: "ProcurementCharge", as: "Chargable"

  accepts_nested_attributes_for :items
  accepts_nested_attributes_for :total_before_tax, :tax_amount, :total_after_tax,
                                :discount_amount, :balance_amount

  validates :purchase_order_status, presence: true
  # validates :items, presence: true

end
