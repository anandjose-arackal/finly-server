# == Schema Information
#
# Table name: invoices
#
#  id                              :integer          not null, primary key
#  address_id                      :integer
#  date                            :date
#  due_date                        :date
#  invoice_number                  :text(65535)
#  tax_type_id                     :integer
#  discount                        :decimal(64, 12)
#  discount_type_id                :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  gross_amount_id                 :integer
#  net_amount_id                   :integer
#  inclusive_of_taxes              :boolean
#  amount_id                       :integer
#  tds                             :decimal(64, 12)
#  tds_type_id                     :integer
#  gst_type_id                     :integer
#  payment_id                      :integer
#  discount_amount_id              :integer
#  tds_amount_id                   :integer
#  tax_amount_id                   :integer
#  tax                             :decimal(64, 12)
#  category_id                     :integer
#  original_amount_id              :integer
#  advance_amount_id               :integer
#  advance_type_id                 :integer
#  advance                         :decimal(20, 10)
#  freight_amount_id               :integer
#  freight_type_id                 :integer
#  freight                         :decimal(20, 10)
#  roundoff_amount                 :decimal(20, 10)
#  balance_due_id                  :integer
#  taxable_amount_id               :integer
#  cost_center_id                  :integer
#  tds_slab_id                     :integer
#  invoice_status_id               :integer
#  company_id                      :integer
#  created_by_user_id              :integer
#  paid_amount_id                  :integer
#  vendor_id                       :integer
#  receiving_account_id            :integer
#  receiving_account_type          :string(255)
#  note                            :text(65535)
#  procurement_id                  :integer
#  remaining_amount_id             :integer
#  invoice_type_id                 :integer
#  location_id                     :integer
#  delivery_location_id            :integer
#  payment_term_id                 :integer
#  department_id                   :integer
#  sub_department_id               :integer
#  policy_id                       :integer
#  controlling_level_id            :integer
#  controlling_user_id             :integer
#  controlling_user_role_id        :integer
#  controlling_for_user_id         :integer
#  controlling_for_user_role_id    :integer
#  billing_address                 :text(65535)
#  shipping_address                :text(65535)
#  is_template                     :boolean          default(FALSE)
#  template_name                   :string(255)
#  is_deleted                      :boolean          default(FALSE)
#  resource_template_id            :integer
#  invoice_id                      :string(255)
#  deleted_at                      :datetime
#  submitted_at                    :datetime
#  approved_at                     :datetime
#  po_adjusted_advance             :integer
#  po_advance                      :integer
#  po_prev_adjusted_advance        :integer
#  advance_amount_required         :boolean          default(FALSE)
#  gstin_location_id               :bigint(8)
#  transaction_service_period_from :date
#  transaction_service_period_to   :date
#  proforma_invoice_id             :integer
#  proforma_advance                :integer
#  total_proforma_advance          :decimal(20, 2)
#  cost_allocation_items           :boolean          default(FALSE)
#

require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
