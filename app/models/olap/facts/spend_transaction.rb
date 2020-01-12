# == Schema Information
#
# Table name: olap_facts_spend_transactions
#
#  id                                    :bigint           not null, primary key
#  finly_ref_id                          :bigint           not null
#  finly_ref_created_at                  :datetime
#  finly_ref_updated_at                  :datetime
#  document_type                         :string(255)
#  document_id                           :integer
#  parent_document_type                  :string(255)
#  parent_document_id                    :integer
#  is_reimbursable                       :boolean
#  reimbursed_on_id                      :integer
#  status                                :string(255)
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
#  transaction_created_at_id             :integer
#  transaction_submitted_at_id           :integer
#  transaction_approved_at_id            :integer
#  transaction_rejected_at_id            :integer
#  transaction_rejection_count           :integer
#  has_violation                         :boolean
#  violation_description                 :string(255)
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
#  payment_mode                          :string(255)
#  quantity                              :decimal(10, )
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
#  advance_amount_requested_id           :integer
#  advance_amount_paid_id                :integer
#  advance_percentage                    :decimal(10, )
#  credit_days                           :integer
#  reimbursement_amount_id               :integer
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#

class Olap::Facts::SpendTransaction < OlapRecord

  belongs_to :document, polymorphic: true
  belongs_to :parent_document, polymorphic: true

  # Employee Expenses
  belongs_to :reimbursed_on, class_name: "Olap::Dimensions::FiscalTime"

  # Header - General
  belongs_to :parent_cost_center_id, class_name: "Olap::Dimensions::CostCenter"
  belongs_to :cost_center_id, class_name: "Olap::Dimensions::CostCenter"
  belongs_to :parent_location_id, class_name: "Olap::Dimensions::Location"
  belongs_to :location_id, class_name: "Olap::Dimensions::Location"
  belongs_to :parent_department_id, class_name: "Olap::Dimensions::Department"
  belongs_to :department_id, class_name: "Olap::Dimensions::Department"
  belongs_to :parent_category_id, class_name: "Olap::Dimensions::Category"
  belongs_to :category_id, class_name: "Olap::Dimensions::Category"
  belongs_to :policy_id, class_name: "Olap::Dimensions::Policy"
  belongs_to :owner_id, class_name: "Olap::Dimensions::User"
  belongs_to :service_period_start_id, class_name: "Olap::Dimensions::FiscalTime"
  belongs_to :service_period_end_id, class_name: "Olap::Dimensions::FiscalTime"
  belongs_to :date_id, class_name: "Olap::Dimensions::FiscalTime"
  belongs_to :transaction_created_at_id, class_name: "Olap::Dimensions::FiscalTime"
  belongs_to :transaction_submitted_at_id, class_name: "Olap::Dimensions::FiscalTime"
  belongs_to :transaction_approved_at_id, class_name: "Olap::Dimensions::FiscalTime"
  belongs_to :transaction_rejected_at_id, class_name: "Olap::Dimensions::FiscalTime"

  # Payee
  belongs_to :vendor_id
  belongs_to :vendor_location_id
  belongs_to :shipping_location_id, class_name: "Olap::Dimensions::Location"
  belongs_to :billing_location_id, class_name: "Olap::Dimensions::Location"
  belongs_to :vendor_confirmed_at, class_name: "Olap::Dimensions::FiscalTime"
  # belongs_to :payment_mode

  # Item
  belongs_to :estimated_delivery_date_id, class_name: "Olap::Dimensions::FiscalTime"
  belongs_to :delivery_completed_on_id, class_name: "Olap::Dimensions::FiscalTime"
  belongs_to :item_id, class_name: "Olap::Dimensions::Item"

  # Spend
  belongs_to :amount_id, class_name: "Olap::Dimensions::Amount"
  belongs_to :basic_amount_id, class_name: "Olap::Dimensions::Amount"
  belongs_to :tax_amount_id, class_name: "Olap::Dimensions::Amount"
  belongs_to :tds_amount_id, class_name: "Olap::Dimensions::Amount"
  belongs_to :cgst_amount_id, class_name: "Olap::Dimensions::Amount"
  belongs_to :sgst_amount_id, class_name: "Olap::Dimensions::Amount"
  belongs_to :igst_amount_id, class_name: "Olap::Dimensions::Amount"
  belongs_to :advance_amount_requested_id, class_name: "Olap::Dimensions::Amount"
  belongs_to :advance_amount_paid_id, class_name: "Olap::Dimensions::Amount"
  belongs_to :reimbursement_amount_id, class_name: "Olap::Dimensions::Amount"

end
