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

class Olap::Facts::SpendTransactions::ExpenseReport < Olap::Facts::SpendTransaction



end
