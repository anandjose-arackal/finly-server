# == Schema Information
#
# Table name: olap_facts_spends
#
#  id                                    :bigint           not null, primary key
#  finly_ref_id                          :bigint           not null
#  finly_ref_created_at                  :datetime
#  finly_ref_updated_at                  :datetime
#  is_reimbursement                      :boolean
#  reimbursement_on_id                   :integer
#  description                           :string(255)
#  detailed_description                  :text(65535)
#  parent_cost_center_id                 :integer
#  cost_center_id                        :integer
#  parent_location_id                    :integer
#  location_id                           :integer
#  parent_department_id                  :integer
#  department_id                         :integer
#  parent_category_id                    :integer
#  category_id                           :integer
#  policy_id                             :integer
#  owner_id                              :integer
#  service_period_start_id               :integer
#  service_period_end_id                 :integer
#  date_id                               :integer
#  is_employee_expense                   :boolean
#  is_vendor_payment                     :boolean
#  vendor_id                             :integer
#  vendor_location_id                    :integer
#  vendor_name                           :string(255)
#  shipping_location_id                  :integer
#  billing_location_id                   :integer
#  is_gst_registered                     :boolean
#  is_msme_registered                    :boolean
#  is_composite_vendor                   :boolean
#  vendor_confirmed_at_id                :integer
#  days_for_confirmation                 :integer
#  payment_mode                          :integer
#  has_purchase_request                  :boolean
#  has_purchase_order                    :boolean
#  has_grn                               :boolean
#  has_invoice                           :boolean
#  has_agreement                         :boolean
#  quantity_requested                    :decimal(10, )
#  quantity_issued_from_inventory        :decimal(10, )
#  quantity_purchased                    :decimal(10, )
#  quantity_cancelled                    :decimal(10, )
#  quantity_received                     :decimal(10, )
#  quantity_invoiced                     :decimal(10, )
#  quantity_paid                         :decimal(10, )
#  quantity_pending_purchase             :decimal(10, )
#  quantity_pending_receipt              :decimal(10, )
#  quantity_pending_invoice              :decimal(10, )
#  quantity_pending_payment              :decimal(10, )
#  purchased_on_id                       :integer
#  estimated_delivery_date_id            :integer
#  delivery_completed_on_id              :integer
#  is_delivered_on_time                  :boolean
#  has_on_time_delivery                  :boolean
#  has_late_delivery                     :boolean
#  delivery_delayed_days                 :integer
#  quantity_delivered_on_time            :decimal(10, )
#  quantity_delivered_on_time_percentage :decimal(10, )
#  quantity_delivered_late               :decimal(10, )
#  quantity_delivered_late_percentage    :decimal(10, )
#  quantity_purchased_percentage         :decimal(10, )
#  quantity_received_percentage          :decimal(10, )
#  quantity_invoiced_percentage          :decimal(10, )
#  quantity_cancelled_percentage         :decimal(10, )
#  quantity_paid_percentage              :decimal(10, )
#  is_exceeding_budget                   :boolean
#  item_type                             :string(255)
#  item_id                               :integer
#  asset_type                            :string(255)
#  amount_id                             :integer
#  basic_amount_id                       :integer
#  tax_amount_id                         :integer
#  tds_amount_id                         :integer
#  tax_type                              :string(255)
#  tax_percentage                        :decimal(10, )
#  cgst_amount_id                        :integer
#  sgst_amount_id                        :integer
#  igst_amount_id                        :integer
#  cgst_percentage                       :decimal(10, )
#  sgst_percentage                       :decimal(10, )
#  igst_percentage                       :decimal(10, )
#  amount_estimated_id                   :integer
#  amount_purchased_id                   :integer
#  amount_received_id                    :integer
#  amount_invoiced_id                    :integer
#  amount_paid_id                        :integer
#  amount_pending_purchase_id            :integer
#  amount_pending_receipt_id             :integer
#  amount_pending_invoice_id             :integer
#  amount_pending_payment_id             :integer
#  advance_amount_requested_id           :integer
#  advance_amount_paid_id                :integer
#  advance_percentage                    :decimal(10, )
#  credit_days                           :integer
#  estimated_deviation_id                :integer
#  estimated_deviation_percentage        :decimal(10, )
#  reimbursement_amount_id               :decimal(10, )
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  type                                  :string(255)
#

class Olap::Facts::Spend < OlapRecord

  belongs_to :reimbursement_on, class_name: "Olap::Dimensions::FiscalTime"
  belongs_to :parent_cost_center, class_name: "Olap::Dimensions::CostCenter", primary_key: :finly_ref_id
  belongs_to :cost_center, class_name: "Olap::Dimensions::CostCenter", primary_key: :finly_ref_id
  belongs_to :parent_location, class_name: "Olap::Dimensions::Location", primary_key: :finly_ref_id
  belongs_to :location, class_name: "Olap::Dimensions::Location", primary_key: :finly_ref_id
  belongs_to :parent_department, class_name: "Olap::Dimensions::Department", primary_key: :finly_ref_id
  belongs_to :department, class_name: "Olap::Dimensions::Department", primary_key: :finly_ref_id
  belongs_to :parent_category, class_name: "Olap::Dimensions::Category", primary_key: :finly_ref_id
  belongs_to :category, class_name: "Olap::Dimensions::Category", primary_key: :finly_ref_id
  belongs_to :policy, class_name: "Olap::Dimensions::Policy", primary_key: :finly_ref_id
  belongs_to :owner, class_name: "Olap::Dimensions::User", primary_key: :finly_ref_id
  belongs_to :service_period_start, class_name: "Olap::Dimensions::FiscalTime"
  belongs_to :service_period_end, class_name: "Olap::Dimensions::FiscalTime"
  belongs_to :date, class_name: "Olap::Dimensions::FiscalTime"
  belongs_to :payable_created_at, class_name: "Olap::Dimensions::FiscalTime"
  belongs_to :payable_submitted_at, class_name: "Olap::Dimensions::FiscalTime"
  belongs_to :payable_approved_at, class_name: "Olap::Dimensions::FiscalTime"
  #belongs_to :vendor, class_name: "Olap::Dimensions::Vendor", primary_key: :finly_ref_id
  #belongs_to :vendor_location, class_name: "Olap::Dimensions::VendorLocation", primary_key: :finly_ref_id
  #belongs_to :shipping_location, class_name: "Olap::Dimensions::Address", primary_key: :finly_ref_id
  #belongs_to :billing_location, class_name: "Olap::Dimensions::Address", primary_key: :finly_ref_id
  belongs_to :vendor_confirmed_at, class_name: "Olap::Dimensions::FiscalTime"
  belongs_to :purchased_on, class_name: "Olap::Dimensions::FiscalTime"
  belongs_to :estimated_delivery_date, class_name: "Olap::Dimensions::FiscalTime"
  belongs_to :delivery_completed_on, class_name: "Olap::Dimensions::FiscalTime"
  belongs_to :amount, class_name: "Olap::Dimensions::Amount"
  belongs_to :basic_amount, class_name: "Olap::Dimensions::Amount"
  belongs_to :tax_amount, class_name: "Olap::Dimensions::Amount"
  belongs_to :tds_amount, class_name: "Olap::Dimensions::Amount"
  belongs_to :cgst_amount, class_name: "Olap::Dimensions::Amount"
  belongs_to :sgst_amount, class_name: "Olap::Dimensions::Amount"
  belongs_to :igst_amount, class_name: "Olap::Dimensions::Amount"
  belongs_to :amount_estimated, class_name: "Olap::Dimensions::Amount"
  belongs_to :amount_purchased, class_name: "Olap::Dimensions::Amount"
  belongs_to :amount_received, class_name: "Olap::Dimensions::Amount"
  belongs_to :amount_invoiced, class_name: "Olap::Dimensions::Amount"
  belongs_to :amount_paid, class_name: "Olap::Dimensions::Amount"
  belongs_to :amount_pending_purchase, class_name: "Olap::Dimensions::Amount"
  belongs_to :amount_pending_receipt, class_name: "Olap::Dimensions::Amount"
  belongs_to :amount_pending_invoice, class_name: "Olap::Dimensions::Amount"
  belongs_to :amount_pending_payment, class_name: "Olap::Dimensions::Amount"
  belongs_to :advance_amount_requested, class_name: "Olap::Dimensions::Amount"
  belongs_to :advance_amount_paid, class_name: "Olap::Dimensions::Amount"
  belongs_to :estimated_deviation, class_name: "Olap::Dimensions::Amount"
  belongs_to :reimbursement_amount, class_name: "Olap::Dimensions::Amount"

end
