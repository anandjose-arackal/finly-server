# == Schema Information
#
# Table name: general_invoices
#
#  id                                    :bigint           not null, primary key
#  vendor_id                             :integer
#  department_id                         :integer
#  location_id                           :integer
#  cost_center_id                        :integer
#  payment_term_id                       :integer
#  auto_pay                              :boolean
#  note                                  :text(65535)
#  billing_type_id                       :integer
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  address_id                            :integer
#  date                                  :date
#  due_date                              :date
#  invoice_number                        :text(65535)
#  tax_type_id                           :integer
#  discount                              :decimal(64, 12)
#  discount_type_id                      :integer
#  gross_amount_id                       :integer
#  net_amount_id                         :integer
#  inclusive_of_taxes                    :boolean
#  amount_id                             :integer
#  tds                                   :decimal(64, 12)
#  tds_type_id                           :integer
#  gst_type_id                           :integer
#  payment_id                            :integer
#  discount_amount_id                    :integer
#  tds_amount_id                         :integer
#  tax_amount_id                         :integer
#  tax                                   :decimal(64, 12)
#  category_id                           :integer
#  original_amount_id                    :integer
#  advance_amount_id                     :integer
#  advance_type_id                       :integer
#  advance                               :decimal(20, 10)
#  freight_amount_id                     :integer
#  freight_type_id                       :integer
#  freight                               :decimal(20, 10)
#  roundoff_amount                       :decimal(20, 10)
#  balance_due_id                        :integer
#  taxable_amount_id                     :integer
#  tds_slab_id                           :integer
#  invoice_status_id                     :integer
#  company_id                            :integer
#  created_by_user_id                    :integer
#  paid_amount_id                        :integer
#  receiving_account_id                  :integer
#  receiving_account_type                :string(255)
#  procurement_id                        :integer
#  remaining_amount_id                   :integer
#  invoice_type_id                       :integer
#  sub_department_id                     :integer
#  is_template                           :boolean          default(FALSE)
#  template_name                         :string(255)
#  is_deleted                            :boolean          default(FALSE)
#  resource_template_id                  :integer
#  invoice_id                            :string(255)
#  deleted_at                            :datetime
#  gstin_location_id                     :integer
#  transaction_service_period_from       :date
#  transaction_service_period_to         :date
#  cost_allocation_items                 :boolean          default(FALSE)
#  narration                             :text(65535)
#  po_number                             :string(255)
#  payment_agreement_id                  :integer
#  bank_account_id                       :integer
#  vendor_location_id                    :integer
#  rejection_note                        :text(65535)
#  invoice_frequency_id                  :integer
#  billing_start_date                    :datetime
#  billing_day_of_month                  :integer
#  payment_agreement_upcoming_date       :date
#  is_payment_agreement_upcoming_invoice :boolean
#  recurring_invoice_id                  :integer
#  vendor_poc_id                         :integer
#  vlpm_id                               :integer
#  client_note                           :text(65535)
#  start_date                            :date
#  end_date                              :date
#  lock_in_period                        :integer
#  rent_free_period                      :integer
#  tenancy_period                        :integer
#  po_adjusted_advance                   :integer
#  po_advance                            :integer
#  po_prev_adjusted_advance              :integer
#  advance_amount_required               :boolean
#  proforma_invoice_id                   :integer
#  proforma_advance                      :integer
#  total_proforma_advance                :integer
#  delivery_location_id                  :integer
#  template_invoice_id                   :integer
#  prepaid                               :boolean
#  fixed_periodic_template               :boolean
#  escalation_percentage                 :float(24)
#  override_invoice_id                   :string(255)
#  total_invoice_amount_id               :integer
#  available_invoice_amount_id           :integer
#  include_tax_and_tds                   :boolean          default(FALSE)
#  rcm_enabled                           :boolean
#

FactoryBot.define do
  factory :general_invoice do
    vendor_id { 1 }
    department_id { 1 }
    location_id { 1 }
    cost_center_id { 1 }
    payment_term_id { 1 }
    auto_pay { false }
    note { "MyText" }
    billing_type_id { 1 }
  end
end
