# == Schema Information
#
# Table name: outward_invoices
#
#  id                      :integer          not null, primary key
#  customer_id             :integer
#  date                    :date
#  due_date                :date
#  amount_id               :integer
#  discount_amount_id      :integer
#  tax_amount_id           :integer
#  paid_amount_id          :integer
#  advance                 :decimal(10, 5)
#  freight_amount_id       :integer
#  balance_due_id          :integer
#  roundoff_amount         :decimal(10, 5)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  policy_id               :integer
#  invoice_status_id       :integer
#  company_id              :integer
#  invoice_number          :string(255)
#  gst_type_id             :integer
#  inclusive_of_taxes      :boolean
#  advance_amount_id       :integer
#  net_amount_id           :integer
#  virtual_account_id      :integer
#  billing_address         :text(65535)
#  shipping_address        :text(65535)
#  email                   :string(255)
#  mobile_number           :string(255)
#  override_invoice_number :boolean
#  is_deleted              :boolean
#  sequence_start          :string(255)
#  prefix                  :string(255)
#  total_payable_id        :integer
#  roundoff_total_enabled  :boolean
#  memo                    :string(255)
#  customer_memo           :text(65535)
#  reminders               :text(65535)
#  payment_term_id         :integer
#  user_id                 :integer
#  outward_invoice_type_id :integer          default(1)
#  terms                   :text(65535)
#  location_id             :integer
#  tds_slab_id             :integer
#

require 'test_helper'

class OutwardInvoiceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
