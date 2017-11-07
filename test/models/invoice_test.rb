# == Schema Information
#
# Table name: invoices
#
#  id                 :integer          not null, primary key
#  address_id         :integer
#  date               :date
#  due_date           :date
#  invoice_number     :string(255)
#  tax_type_id        :integer
#  discount           :decimal(64, 12)
#  discount_type_id   :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  gross_amount_id    :integer
#  net_amount_id      :integer
#  inclusive_of_taxes :boolean
#  amount_id          :integer
#  tds                :decimal(64, 12)
#  tds_type_id        :integer
#  gst_type_id        :integer
#  payment_id         :integer
#  discount_amount_id :integer
#  sgst_amount_id     :integer
#  csgt_amount_id     :integer
#  igst_amount_id     :integer
#  tds_amount_id      :integer
#  tax_amount_id      :integer
#  tax_rate           :decimal(64, 12)
#

require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
