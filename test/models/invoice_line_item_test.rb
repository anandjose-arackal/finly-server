# == Schema Information
#
# Table name: invoice_line_items
#
#  id                     :integer          not null, primary key
#  invoice_id             :integer
#  description            :string(255)
#  quantity               :integer
#  rate                   :decimal(20, 10)
#  tax                    :decimal(20, 10)
#  discount               :decimal(20, 10)
#  category_id            :integer
#  gst_type_id            :integer
#  tax_amount_id          :integer
#  discount_amount_id     :integer
#  amount_id              :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  net_amount_id          :integer
#  hsn_sac                :string(255)
#  taxable_amount_id      :integer
#  parent_type            :string(255)
#  parent_id              :string(255)
#  inventory_line_item_id :integer
#  item_info              :text(65535)
#  comment                :string(255)
#  account                :string(255)
#  tax_rate_id            :integer
#  buying_price           :decimal(10, 5)
#  markup                 :decimal(10, 5)
#  profit                 :decimal(10, 5)
#  customer_id            :integer
#  brand                  :string(255)
#  model_number           :string(255)
#  date_of_inward         :string(255)
#  year_of_registration   :string(255)
#  kms_driven             :decimal(10, 5)
#  expected_selling_price :decimal(10, 5)
#  owner_details          :string(255)
#  parking_charges        :decimal(10, 5)
#  billable               :boolean
#  registration_number    :string(255)
#  vendor_id              :integer
#

require 'test_helper'

class InvoiceLineItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
